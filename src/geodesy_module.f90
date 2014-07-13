!*****************************************************************************************    
    module geodesy_module
!*****************************************************************************************
!****h* FAT/geodesy_module
!
!  NAME
!    geodesy_module
!
!  DESCRIPTION
!    Geodesy routines.
!
!*****************************************************************************************    
    
    use kind_module,    only: wp
    
    implicit none
    
    private
    
    public :: heikkinen
    public :: olson
    
    contains
!*****************************************************************************************    
     
!*****************************************************************************************
    pure subroutine heikkinen(rvec, a, b, h, lon, lat)
!*****************************************************************************************
!****f* geodesy_module/heikkinen
!
!  NAME
!    heikkinen
!
!  DESCRIPTION
!    Heikkinen routine for cartesian to geodetic transformation
!
!  SEE ALSO
!    [1] M. Heikkinen, “Geschlossene formeln zur berechnung raumlicher 
!        geodatischer koordinaten aus rechtwinkligen Koordinaten”. 
!        Z. Ermess., 107 (1982), 207-211 (in German).
!    [2] E. D. Kaplan, “Understanding GPS: Principles and Applications”, 
!        Artech House, 1996.
!
!  AUTHOR
!    Jacob Williams
!
!  SOURCE

    implicit none
    
    real(wp),dimension(3),intent(in) :: rvec     !position vector [km]
    real(wp),intent(in)  :: a                    !geoid semimajor axis [km]
    real(wp),intent(in)  :: b                    !geoid semiminor axis [km]
    real(wp),intent(out) :: h                    !geodetic altitude [km]
    real(wp),intent(out) :: lon                  !longitude [rad]
    real(wp),intent(out) :: lat                  !geodetic latitude [rad]

    real(wp) :: f,e_2,ep,r,e2,ff,g,c,s,pp,q,r0,u,v,z0,x,y,z,z2,r2,tmp,a2,b2
            
    x   = rvec(1)
    y   = rvec(2)
    z   = rvec(3)       
    a2  = a*a
    b2  = b*b
    f   = (a-b)/a
    e_2 = (2.0_wp*f-f*f)
    ep  = sqrt(a2/b2 - 1.0_wp)
    z2  = z*z
    r   = sqrt(x**2 + y**2)
    r2  = r*r
    e2  = a2 - b2
    ff  = 54.0_wp * b2 * z2
    g   = r2 + (1.0_wp - e_2)*z2 - e_2*e2
    c   = e_2**2 * ff * r2 / g**3
    s   = (1.0_wp + c + sqrt(c**2 + 2.0_wp*c))**(1.0_wp/3.0_wp)
    pp  = ff / ( 3.0_wp*(s + 1.0_wp/s + 1.0_wp)**2 * g**2 )
    q   = sqrt( 1.0_wp + 2.0_wp*e_2**2 * pp )
    r0  = -pp*e_2*r/(1.0_wp+q) + &
            sqrt( max(0.0_wp, 1.0_wp/2.0_wp * a2 * (1.0_wp + 1.0_wp/q) - &
                ( pp*(1.0_wp-e_2)*z2 )/(q*(1.0_wp+q)) - &
                1.0_wp/2.0_wp * pp * r2) )
    u   = sqrt( (r - e_2*r0)**2 + z2 )
    v   = sqrt( (r - e_2*r0)**2 + (1.0_wp - e_2)*z2 )
    z0  = b**2 * z / (a*v)
    
    h   = u*(1.0_wp - b2/(a*v) )
    lat = atan2( (z + ep**2*z0), r )
    lon = atan2( y, x )
        
    end subroutine heikkinen
!******************************************************************************** 

!********************************************************************************    
    pure subroutine olson(rvec, a, b, h, long, lat)
!*****************************************************************************************
!****f* geodesy_module/olson
!
!  NAME
!    olson
!
!  DESCRIPTION
!    Olson routine for cartesian to geodetic transformation.
!
!  SEE ALSO
!   [1] Olson, D. K., Converting Earth-Centered, Earth-Fixed Coordinates to
!       Geodetic Coordinates, IEEE Transactions on Aerospace and Electronic
!       Systems, 32 (1996) 473-476.
!
!  AUTHOR
!    Jacob Williams
!
!  SOURCE
    
    implicit none
    
    real(wp),dimension(3),intent(in) :: rvec     !position vector [km]
    real(wp),intent(in)  :: a                    !geoid semimajor axis [km]
    real(wp),intent(in)  :: b                    !geoid semiminor axis [km]
    real(wp),intent(out) :: h                    !geodetic altitude [km]
    real(wp),intent(out) :: long                !longitude [rad]
    real(wp),intent(out) :: lat                    !geodetic latitude [rad]
    
    real(wp) :: f,x,y,z,e2,a1,a2,a3,a4,a5,a6,w,zp,&
                w2,r2,r,s2,c2,u,v,s,ss,c,g,rg,rf,m,p,z2
    
    x    = rvec(1)                
    y    = rvec(2)                
    z    = rvec(3)                
    f    = (a-b)/a
    e2 = f * (2.0_wp - f)
    a1 = a * e2
    a2 = a1 * a1
    a3 = a1 * e2 / 2.0_wp
    a4 = 2.5_wp * a2
    a5 = a1 + a3
    a6 = 1.0_wp - e2 
    zp = abs(z)
    w2 = x*x + y*y
    w  = sqrt(w2)
    z2 = z * z
    r2 = z2 + w2
    r  = sqrt(r2)
    
    if (r < 100.0_wp) then
    
        lat = 0.0_wp
        long = 0.0_wp
        h = -1.0e7_wp
    
    else
    
        s2 = z2 / r2
        c2 = w2 / r2
        u  = a2 / r
        v  = a3 - a4 / r
    
        if (c2 > 0.3_wp) then
            s = (zp / r) * (1.0_wp + c2 * (a1 + u + s2 * v) / r)
            lat = asin(s)
            ss = s * s
            c = sqrt(1.0_wp - ss)
        else
            c = (w / r) * (1.0_wp - s2 * (a5 - u - c2 * v) / r)
            lat = acos(c)
            ss = 1.0_wp - c * c
            s = sqrt(ss)
        end if
    
        g   = 1.0_wp - e2 * ss
        rg  = a / sqrt(g)
        rf  = a6 * rg
        u   = w - rg * c
        v   = zp - rf * s
        f   = c * u + s * v
        m   = c * v - s * u
        p   = m / (rf / g + f)
        lat = lat + p
        if (z < 0.0_wp) lat = -lat
        h = f + m * p / 2.0_wp
        long = atan2( y, x )   
    
    end if
            
    end subroutine olson    
!********************************************************************************    
       
!*****************************************************************************************    
    end module geodesy_module
!*****************************************************************************************    