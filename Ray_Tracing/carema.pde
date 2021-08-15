class Camera {
  float aspect_ratio;
  float viewport_height;
  float viewport_width;
  Vec3 u;
  Vec3 v;
  Vec3 w;
  float lens_radius;
  
  Vec3 origin;
  Vec3 lower_left_corner;
  Vec3 horizontal;
  Vec3 vertical;
  float time0=0.0;
  float time1=0.0;
  
  Camera(Vec3 lookfrom, Vec3 lookat, Vec3 vup, float vfov, float aspect_ratio, float aperture, float focus_dist,float t0,float t1) {

    float theda=map(vfov, 0, 360, 0, 2*PI);
    float h=tan(theda/2);

    this.aspect_ratio=aspect_ratio;
    viewport_height=2.0*h;
    viewport_width=viewport_height*aspect_ratio;

    w=Vec3.unit_vector(lookfrom.sub(lookat));
    u=Vec3.unit_vector(Vec3.cross(vup, w));
    v=Vec3.cross(w, u);

    origin=lookfrom;
    horizontal=u.mult(viewport_width*focus_dist);
    vertical=v.mult(viewport_height*focus_dist);    
    lower_left_corner=origin.sub(horizontal.divide(2)).sub(vertical.divide(2)).sub(w.mult(focus_dist));
    
    lens_radius=aperture/2;
    time0=t0;
    time1=t1;
  }
  Ray get_ray(float s, float t) {
  Vec3 rd=random_in_unit_disk().mult(lens_radius);
  Vec3 offset=u.mult(rd.x()).add(v.mult(rd.y()));
    return new Ray(origin.add(offset), lower_left_corner.add(horizontal.mult(s)).add(vertical.mult(t)).sub(origin).sub(offset),random(time0,time1));
  }
}
