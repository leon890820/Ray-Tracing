class hit_record {
  Vec3 p=new Vec3();
  Vec3 normal=new Vec3();
  Material mat_ptr;
  float t;
  float u;
  float v;
  boolean front_face;

  void set_face_normal(Ray r, Vec3 outward_normal) {
    front_face=Vec3.dot(r.dir(), outward_normal)<0;
    normal=front_face?outward_normal:outward_normal.mult(-1);
  }
  void copy(hit_record temp_rec) {
    p=temp_rec.p;
    normal=temp_rec.normal;
    t=temp_rec.t;
    u=temp_rec.u;
    v=temp_rec.v;
    front_face=temp_rec.front_face;
    mat_ptr=temp_rec.mat_ptr;
  }
}
abstract class Hittable {
  abstract boolean hit(Ray r, float t_min, float t_max, hit_record rec);
  abstract boolean boundingBox(float time0,float time1, AABB outputBox);
  
}

class hittable_list extends Hittable {
  ArrayList<Hittable> objects=new ArrayList<Hittable>();
  hittable_list() {
  }
  hittable_list(Hittable object) {
    add(object);
  }
  void clear() {
    objects.clear();
  }
  void add(Hittable object) {
    objects.add(object);
  }
  int size(){
    return objects.size();
  }

  @Override
    boolean hit(Ray r, float t_min, float t_max, hit_record rec) {
    hit_record temp_rec=new hit_record();
    boolean hit_anything=false;
    float closest_so_far=t_max;

    for (Hittable object : objects) {

      if (object.hit(r, t_min, closest_so_far, temp_rec)) {        
        hit_anything=true;
        closest_so_far=temp_rec.t;
        rec.copy(temp_rec);
      }
    }

    return hit_anything;
  }
  
  @Override
  boolean boundingBox(float time0,float time1, AABB outputBox){
    if(objects.isEmpty()) return false;
    
    AABB tempBox=new AABB(new Vec3(0,0,0),new Vec3(0,0,0));
    boolean firstBox=true;
    for(Hittable object:objects){
      if(!object.boundingBox(time0,time1,tempBox)) return false;
      outputBox=firstBox?tempBox:surroundingBox(outputBox,tempBox);
      firstBox=false;
    }
  
    return true;
  }
}


class Sphere extends Hittable {
  Vec3 center;
  float radius;
  Material mat_prt;
  Sphere() {
  }
  Sphere(Vec3 cen, float r,Material m) {
    center=cen;
    radius=r;
    mat_prt=m;
  }

  @Override
    public boolean hit(Ray r, float t_min, float t_max, hit_record rec) {
    
    Vec3 oc=r.orig().sub(center);
    float a=r.dir().length_squared();
    float half_b=Vec3.dot(oc, r.dir());
    float c=oc.length_squared()-radius*radius;

    float discriminant=half_b*half_b-a*c;
    if (discriminant<0) return false;
    float sqrt_discriminant=sqrt(discriminant);

    float root=(-half_b-sqrt_discriminant)/a;
    if (root < t_min || t_max < root) {
      root = (-half_b + sqrt_discriminant) / a;
      if (root < t_min || t_max < root)
        return false;
    }

    rec.t=root;
    rec.p=r.at(rec.t);

    Vec3 outward_normal=rec.p.sub(center).divide(radius);
    rec.set_face_normal(r, outward_normal);
    float[] uv=getSphereUV(outward_normal);
    rec.u=uv[0];
    rec.v=uv[1];
    rec.mat_ptr=mat_prt;
     
    return true;
  }
  
  float[] getSphereUV(Vec3 p){
    float theta=acos(-p.y());
    float phi=atan2(-p.z(),p.x())+PI;
    float[] uv={phi/(2*PI),theta/PI};
    
    return uv;
  }
  
  @Override
  boolean boundingBox(float time0,float time1, AABB outputBox){
    AABB ob=new AABB(Vec3.sub(center,new Vec3(radius,radius,radius)),Vec3.add(center,new Vec3(radius,radius,radius)));
    copyAABB(outputBox,ob);
    return true;
  }
}



class MovingSphere extends Hittable{
  Vec3 center0,center1;
  float time0,time1;
  float radius;
  Material mat_ptr;
  MovingSphere(Vec3 cen0,Vec3 cen1,float t0,float t1,float r,Material m){
    center0=cen0;
    center1=cen1;
    time0=t0;
    time1=t1;
    radius=r;
    mat_ptr=m;
  }
  Vec3 center(float time){
    float t=(time-time0)/(time1-time0);
    Vec3 c=Vec3.sub(center1,center0).mult(t);
    return Vec3.add(center0,c);
  }
  
  @Override
  public boolean hit(Ray r, float t_min, float t_max, hit_record rec) {
    Vec3 oc=r.orig().sub(center(r.time));
    float a=r.dir().length_squared();
    float half_b=Vec3.dot(oc, r.dir());
    float c=oc.length_squared()-radius*radius;

    float discriminant=half_b*half_b-a*c;
    if (discriminant<0) return false;
    float sqrt_discriminant=sqrt(discriminant);

    float root=(-half_b-sqrt_discriminant)/a;
    if (root < t_min || t_max < root) {
      root = (-half_b + sqrt_discriminant) / a;
      if (root < t_min || t_max < root)
        return false;
    }

    rec.t=root;
    rec.p=r.at(rec.t);

    Vec3 outward_normal=rec.p.sub(center(r.time)).divide(radius);
    rec.set_face_normal(r, outward_normal);
    rec.mat_ptr=mat_ptr;
    return true;
      
  }
  
  @Override
  boolean boundingBox(float _time0,float _time1, AABB outputBox){
    AABB box0=new AABB(Vec3.sub(center(_time0),new Vec3(radius,radius,radius)),Vec3.add(center(_time0),new Vec3(radius,radius,radius)));
    AABB box1=new AABB(Vec3.sub(center(_time1),new Vec3(radius,radius,radius)),Vec3.add(center(_time1),new Vec3(radius,radius,radius)));
    copyAABB(outputBox,surroundingBox(box0,box1));
    return true;
  }
  
}

AABB surroundingBox(AABB box0,AABB box1){
  Vec3 small=new Vec3(min(box0.mini().x(),box1.mini().x()),
                      min(box0.mini().y(),box1.mini().y()),
                      min(box0.mini().z(),box1.mini().z()));
  Vec3 big=new Vec3(max(box0.maxi().x(),box1.maxi().x()),
                    max(box0.maxi().y(),box1.maxi().y()),
                    max(box0.maxi().z(),box1.maxi().z()));

  return new AABB(small,big);
}


class XyRect extends Hittable{
  Material mp;
  float x0,x1,y0,y1,k;
  XyRect(float _x0,float _x1,float _y0,float _y1,float _k,Material m){
    x0=_x0;
    x1=_x1;
    y0=_y0;
    y1=_y1;
    k=_k;
    mp=m;
  }
  boolean hit(Ray r, float t_min, float t_max, hit_record rec){
    float t= (k-r.orig().z())/r.dir().z();
    if(t<t_min || t>t_max) return false;
    float x=r.orig().x()+t*r.dir().x();
    float y=r.orig().y()+t*r.dir().y();
    if(x<x0||x>x1||y<y0||y>y1) return false;
    
    rec.u=(x-x0)/(x1-x0);
    rec.v=(y-y0)/(y1-y0);
    rec.t=t;
    Vec3 outwardNormal=new Vec3(0,0,1);
    rec.set_face_normal(r,outwardNormal);
    rec.mat_ptr=mp;
    rec.p=r.at(t);
    return true;
  }
  
  boolean boundingBox(float time0,float time1, AABB outputBox){
    AABB ob=new AABB(new Vec3(x0,y0,k-0.0001),new Vec3(x1,y1,k+0.0001));
    copyAABB(outputBox,ob);
    return true;
   
  }
  
  
  
}


class XzRect extends Hittable{
  Material mp;
  float x0,x1,z0,z1,k;
  XzRect(float _x0,float _x1,float _z0,float _z1,float _k,Material m){
    x0=_x0;
    x1=_x1;
    z0=_z0;
    z1=_z1;
    k=_k;
    mp=m;
  }
  boolean hit(Ray r, float t_min, float t_max, hit_record rec){
    float t= (k-r.orig().y())/r.dir().y();
    if(t<t_min || t>t_max) return false;
    float x=r.orig().x()+t*r.dir().x();
    float z=r.orig().z()+t*r.dir().z();
    if(x<x0||x>x1||z<z0||z>z1) return false;
    
    rec.u=(x-x0)/(x1-x0);
    rec.v=(z-z0)/(z1-z0);
    rec.t=t;
    Vec3 outwardNormal=new Vec3(0,1,0);
    rec.set_face_normal(r,outwardNormal);
    rec.mat_ptr=mp;
    rec.p=r.at(t);
    return true;
  }
  
  boolean boundingBox(float time0,float time1, AABB outputBox){
    copyAABB(outputBox,new AABB(new Vec3(x0,k-0.0001,z0),new Vec3(x1,k+0.0001,z1)));
    return true;
   
  }
  
  
  
}


class YzRect extends Hittable{
  Material mp;
  float y0,y1,z0,z1,k;
  YzRect(float _y0,float _y1,float _z0,float _z1,float _k,Material m){
    y0=_y0;
    y1=_y1;
    z0=_z0;
    z1=_z1;
    k=_k;
    mp=m;
  }
  boolean hit(Ray r, float t_min, float t_max, hit_record rec){
    float t= (k-r.orig().x())/r.dir().x();
    if(t<t_min || t>t_max) return false;
    float y=r.orig().y()+t*r.dir().y();
    float z=r.orig().z()+t*r.dir().z();
    if(y<y0||y>y1||z<z0||z>z1) return false;
    
    rec.u=(y-y0)/(y1-y0);
    rec.v=(z-z0)/(z1-z0);
    rec.t=t;
    Vec3 outwardNormal=new Vec3(1,0,0);
    rec.set_face_normal(r,outwardNormal);
    rec.mat_ptr=mp;
    rec.p=r.at(t);
    return true;
  }
  
  
  boolean boundingBox(float time0,float time1, AABB outputBox){
    copyAABB(outputBox,new AABB(new Vec3(k-0.0001,y0,z0),new Vec3(k+0.0001,y1,z1)));
    return true;
   
  }
  
  
  
}

class Triangle extends Hittable{
  Vec3 T1,T2,T3;
  Material mp;
  Triangle(Vec3 T1,Vec3 T2,Vec3 T3,Material m){
    this.T1=T1;
    this.T2=T2;
    this.T3=T3;
    mp=m;
  }
  boolean hit(Ray r, float t_min, float t_max, hit_record rec){
    Vec3 N=Vec3.cross(Vec3.sub(T2,T1),Vec3.sub(T3,T2));
    float t=(Vec3.dot(N,T1)-Vec3.dot(N,r.orig()))/Vec3.dot(N,r.dir());
    if(t<t_min || t>t_max) return false;
    
    Vec3[] vs={T1,T2,T3};
    for(int i=0,j=vs.length-1;i<vs.length;j=i++){
      Vec3 a=Vec3.sub(vs[i],vs[j]);
      float s=Vec3.dot(Vec3.sub(r.at(t),vs[j]),Vec3.cross(a,N));
      if(s>0) return false;
    }
    float[] uv=calculateUV(T1,T2,T3,r.at(t));
    rec.u=uv[0];
    rec.v=uv[1];
    rec.t=t;
    rec.set_face_normal(r,N);
    rec.mat_ptr=mp;
    rec.p=r.at(t);
     
    return true;
  }
  float[] calculateUV(Vec3 A,Vec3 B,Vec3 C,Vec3 P){
    float t=((B.y-C.y)*(A.x-C.x)+(C.x-B.x)*(A.y-C.y));
    float BaryA=((B.y-C.y)*(P.x-C.x)+(C.x-B.x)*(P.y-C.y))/t;
    float BaryB=((C.y-A.y)*(P.x-C.x)+(A.x-C.x)*(P.y-C.y))/t;
    float BaryC=1-BaryA-BaryB;
    float u=BaryA*0+BaryB*1+BaryC*0;
    float v=BaryA*0+BaryB*0+BaryC*1;
    float[] r={u,v};
    return r;
  }
  
  boolean boundingBox(float time0,float time1, AABB outputBox){
    float min_x=min3(T1.x,T2.x,T3.x);
    float min_y=min3(T1.y,T2.y,T3.y);
    float min_z=min3(T1.z,T2.z,T3.z);
    float max_x=max3(T1.x,T2.x,T3.x);
    float max_y=max3(T1.y,T2.y,T3.y);
    float max_z=max3(T1.z,T2.z,T3.z);
    copyAABB(outputBox,new AABB(new Vec3(min_x-0.001,min_y-0.001,min_z-0.001),new Vec3(max_x+0.001,max_y+0.001,max_z+0.001)));
    return true;
   
  }

}

float max3(float a,float b,float c){
  return max(a,max(b,c));
}

float min3(float a,float b,float c){
  return min(a,min(b,c));
}
