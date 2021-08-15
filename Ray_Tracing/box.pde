class Box extends Hittable{
  Vec3 boxMin;
  Vec3 boxMax;
  hittable_list sides;
  Box(Vec3 p0,Vec3 p1,Material m){
    boxMin=p0;
    boxMax=p1;
    sides=new hittable_list();
    sides.add(new XyRect(p0.x(),p1.x(),p0.y(),p1.y(),p1.z(),m));
    sides.add(new XyRect(p0.x(),p1.x(),p0.y(),p1.y(),p0.z(),m));
    
    sides.add(new XzRect(p0.x(),p1.x(),p0.z(),p1.z(),p1.y(),m));
    sides.add(new XzRect(p0.x(),p1.x(),p0.z(),p1.z(),p0.y(),m));
    
    sides.add(new YzRect(p0.y(),p1.y(),p0.z(),p1.z(),p1.x(),m));
    sides.add(new YzRect(p0.y(),p1.y(),p0.z(),p1.z(),p0.x(),m));
  
  }
  @Override
  boolean boundingBox(float time0,float time1, AABB outputBox){
    
    AABB ob=new AABB(boxMin,boxMax);
    
    copyAABB(outputBox,ob);
    
    return true;
  }
  @Override
  boolean hit(Ray r, float t_min, float t_max, hit_record rec){
    return sides.hit(r,t_min,t_max,rec);  
  }


}

void copyAABB(AABB cb,AABB bcb){
  
  cb.maximum=bcb.maximum.copy();
  cb.minimum=bcb.minimum.copy();
}

class Translate extends Hittable{
  Hittable ptr;
  Vec3 offset;
  Translate(Hittable p,Vec3 displacement){
    ptr=p;
    offset=displacement;
    
  }
  @Override
  boolean hit(Ray r, float t_min, float t_max, hit_record rec){
    Ray moveR=new Ray(Vec3.sub(r.orig(),offset),r.dir(),r.time());
    if(!ptr.hit(moveR,t_min,t_max,rec)){
      return false;
    }
    
    rec.p=Vec3.add(rec.p,offset);
    rec.set_face_normal(moveR,rec.normal);
    return true;
  }
  
  @Override
  boolean boundingBox(float time0,float time1, AABB outputBox){
    if(!ptr.boundingBox(time0,time1,outputBox)) return false;
    copyAABB(outputBox,new AABB(Vec3.add(outputBox.mini(),offset),Vec3.add(outputBox.maxi(),offset)));
    return true;
  
  }
}

class RotateY extends Hittable{
  Hittable ptr;
  float sinTheta;
  float cosTheda;
  boolean hasbox;
  AABB bbox;
  RotateY(Hittable p,float angle){
    ptr=p;
    bbox=new AABB(new Vec3(0,0,0),new Vec3(0,0,0));
    float radius=radians(angle);
    sinTheta=sin(radius);
    cosTheda=cos(radius);
    hasbox=ptr.boundingBox(0,1,bbox);
    Vec3 min=new Vec3(INFINITY,INFINITY,INFINITY);
    Vec3 max=new Vec3(-INFINITY,-INFINITY,-INFINITY);    
    for(int i=0;i<2;i+=1){
      for(int j=0;j<2;j+=1){
        for(int k=0;k<2;k+=1){
          float x=i*bbox.maxi().x()+(1-i)*bbox.mini().x();
          float y=j*bbox.maxi().y()+(1-j)*bbox.mini().y();
          float z=k*bbox.maxi().z()+(1-k)*bbox.mini().z();
          
          float newx=cosTheda*x+sinTheta*z;
          float newz=-sinTheta*x+cosTheda*z;
          Vec3 tester=new Vec3(newx,y,newz);
          min.x=min(min.x(),tester.x());
          max.x=max(max.x(),tester.x());
          min.y=min(min.y(),tester.y());
          max.y=max(max.y(),tester.y());
          min.z=min(min.z(),tester.z());
          max.z=max(max.z(),tester.z());
        
        }
      }
      
    }
    
    bbox=new AABB(min,max);
  
  }
  
  @Override
  boolean hit(Ray r, float t_min, float t_max, hit_record rec){
    Vec3 orig=r.orig().copy();
    Vec3 direction=r.dir().copy();
    
    orig.x=cosTheda*r.orig().x()-sinTheta*r.orig().z();
    orig.z=sinTheta*r.orig().x()+cosTheda*r.orig().z();
    
    direction.x=cosTheda*r.dir().x()-sinTheta*r.dir().z();
    direction.z=sinTheta*r.dir().x()+cosTheda*r.dir().z();
    
    Ray rotateR=new Ray(orig,direction,r.time());
    if(!ptr.hit(rotateR,t_min,t_max,rec)) return false;
    Vec3 p=rec.p.copy();
    Vec3 normal=rec.normal.copy();
    
    p.x=cosTheda*rec.p.x()+sinTheta*rec.p.z();
    p.z=-sinTheta*rec.p.x()+cosTheda*rec.p.z();
    
    normal.x=cosTheda*rec.normal.x()+sinTheta*rec.normal.z();
    normal.z=-sinTheta*rec.normal.x()+cosTheda*rec.normal.z();
    
    rec.p=p.copy();
    rec.set_face_normal(rotateR,normal);
    return true;
    
  }
  @Override
  boolean boundingBox(float time0,float time1, AABB outputBox){
    copyAABB(outputBox,bbox);
    return hasbox;
  
  }
}

class ConstantMedium extends Hittable{
  Hittable boundary;
  Material phaseFunction;
  float negInvDesity;
  ConstantMedium(Hittable b,float d,Texture a){
    boundary=b;
    negInvDesity=(-1/d);
    phaseFunction=new Isotropic(a);
  }
  ConstantMedium(Hittable b,float d,Vec3 c){
    boundary=b;
    negInvDesity=(-1/d);
    phaseFunction=new Isotropic(c);
  }
  @Override
  boolean hit(Ray r, float t_min, float t_max, hit_record rec){
    //boolean enableDebug=false;
    //boolean debugging=enableDebug&&random(1)<0.00001;
    //return false;
    hit_record rec1=new hit_record();
    hit_record rec2=new hit_record();
    
    if(!boundary.hit(r,-INFINITY,INFINITY,rec1)) return false;
    if(!boundary.hit(r,rec1.t+0.0001,INFINITY,rec2)) return false;
    
    if(rec1.t<t_min) rec1.t=t_min;
    if(rec2.t>t_max) rec2.t=t_max;
    
    if(rec1.t>=rec2.t) return false;
    if(rec1.t<0) rec1.t=0;
    
    float rayLength=r.dir().length();
    float distanceInsideBoundary=(rec2.t-rec1.t)*rayLength;
    float hitDistance=negInvDesity*log(random(1));
    if(hitDistance>distanceInsideBoundary) return false;
    
    rec.t=rec1.t+hitDistance/rayLength;
    rec.p=r.at(rec.t);
    
    rec.normal=new Vec3(1,0,0);
    rec.front_face=true;
    rec.mat_ptr=phaseFunction;
    
    return true;
    
  
  }
  
  @Override
  boolean boundingBox(float time0,float time1, AABB outputBox){
    return boundary.boundingBox(time0,time1,outputBox);
  }
  
  
}
