static class Vec3 {
  float x;
  float y;
  float z;
  
  Vec3() {
    x=0;
    y=0;
    z=0;
  }
  Vec3(float _x, float _y, float _z) {
    x=_x;
    y=_y;
    z=_z;
  }
  float x() {
    return x;
  }
  float y() {
    return y;
  }
  float z() {
    return z;
  }
  
  float xyz(int i){
    if(i==0) return x;
    else if(i==1) return y;
    else return z;
  }
  public static Vec3 add(Vec3 a, Vec3 b) {
    Vec3 result=new Vec3();
    result.x=a.x+b.x;
    result.y=a.y+b.y;
    result.z=a.z+b.z;
    return result;
  }
  public static Vec3 sub(Vec3 a, Vec3 b) {
    Vec3 result=new Vec3();
    result.x=a.x-b.x;
    result.y=a.y-b.y;
    result.z=a.z-b.z;
    return result;
  }
  public static Vec3 mult(float n, Vec3 a) {
    Vec3 result=new Vec3();
    result.x=n*a.x;
    result.y=n*a.y;
    result.z=n*a.z;
    return result;
  }
  public Vec3 mult(float n) {
    Vec3 result=new Vec3();
    result.x=n*x;
    result.y=n*y;
    result.z=n*z;
    return result;
  }
  public Vec3 divide(float n) {
    Vec3 result=new Vec3();
    result.x=x/n;
    result.y=y/n;
    result.z=z/n;
    return result;
  }
  public static Vec3 cross(Vec3 a, Vec3 b) {
    Vec3 result=new Vec3();
    result.x=a.y*b.z-a.z*b.y;
    result.y=a.z*b.x-a.x*b.z;
    result.z=a.x*b.y-a.y*b.x;
    return result;
  }

  public static float dot(Vec3 a, Vec3 b) {
    return a.x*b.x+a.y*b.y+a.z*b.z;
  }
  public float norm() {
    return sqrt(x*x+y*y+z*z);
  }

  public void print() {
    println("x: "+x+" y: "+y+" z: "+z);
  }
  public static Vec3 unit_vector(Vec3 v) {
    return Vec3.mult(1/v.norm(), v);
  }
  public Vec3 sub(Vec3 b) {
    Vec3 result=new Vec3();
    result.x=x-b.x;
    result.y=y-b.y;
    result.z=z-b.z;
    return result;
  }
  public Vec3 add(Vec3 b) {
    Vec3 result=new Vec3();
    result.x=x+b.x;
    result.y=y+b.y;
    result.z=z+b.z;
    return result;
  }
  public float length_squared(){
    return x*x+y*y+z*z; 
  }
  float length(){
    return sqrt(this.length_squared());
  }
  
  boolean near_zero(){
    float s=1e-8;
    return (abs(x)<s)&&abs(y)<s&&abs(z)<s;
  }
  Vec3 inner_product(Vec3 v){
    Vec3 result=new Vec3();
    result.x=x*v.x;
    result.y=y*v.y;
    result.z=z*v.z;
    return result;
  }
  Vec3 copy(){
  
    return new Vec3(x,y,z);
  }
  void sprintln(){
    println("x : "+x+" y : "+y+" z : "+z);
  }
}

public Vec3 vec_random(){
  return new Vec3(random(1),random(1),random(1));
}
public Vec3 vec_random(float min,float max){
  return new Vec3(random(min,max),random(min,max),random(min,max));
}
public Vec3 random_in_unit_sphere(){
  while(true){
    Vec3 p=vec_random(-1,1);
    if(p.length_squared()>=1) continue;
    return p;
  }

}
Vec3 random_unit_vector(){
  return Vec3.unit_vector(random_in_unit_sphere());

}

Vec3 reflect(Vec3 v,Vec3 n){
  Vec3 r=n.mult(2*Vec3.dot(v,n));
  return v.sub(r);
}

Vec3 refract(Vec3 uv,Vec3 n,float etai_over_etat){
  float cos_theda=min(Vec3.dot(uv.mult(-1),n),1);
  Vec3 r_out_perp=uv.add(n.mult(cos_theda)).mult(etai_over_etat);
  Vec3 r_out_parallel=n.mult(-sqrt(1-r_out_perp.length_squared()));
  return r_out_perp.add(r_out_parallel);
}

Vec3 random_in_unit_disk(){
  while(true){
    Vec3 p=new Vec3(random(-1,1),random(-1,1),0);
    if(p.length_squared()>=1)continue;
    return p;
  }

}
