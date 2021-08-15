static class Ray{
  private Vec3 origin;
  private Vec3 direction;
  private float time=0;
  Ray(Vec3 orig ,Vec3 dir,float _time){
    origin=orig;
    direction=dir;
    time=_time;
  }
  public Vec3 at(float t){
    return Vec3.add(origin,Vec3.mult(t,direction));
  }
  public Vec3 orig(){
    return origin;
  }
  public Vec3 dir(){
    return direction;
  }
  float time(){
    return time;
  }
  
}
