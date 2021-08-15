abstract class Material{
  Material(){}
  abstract boolean scatter(Ray r_in,hit_record rec, Vec3 attenuation, Ray scattered);
  Vec3 emitted(float u,float v,Vec3 p){
    return new Vec3(0,0,0);
  }

}

class Lambertian extends Material{
  Texture albedo;
  Lambertian(Texture a){
    albedo=a;
  }
  Lambertian(Vec3 a){
    albedo=new SolidColor(a);
  }
  
  @Override
  boolean scatter(Ray r_in,hit_record rec, Vec3 attenuation, Ray scattered){
    Vec3 scatter_direction=rec.normal.add(random_unit_vector());
    
    if(scatter_direction.near_zero()){
      scatter_direction=rec.normal;
    }
    
    Vec3copy(scattered.origin,rec.p);
    Vec3copy(scattered.direction,scatter_direction);
    Vec3copy(attenuation,albedo.value(rec.u,rec.v,rec.p));    
    scattered.time=r_in.time();
    return true;
  }

}
void Vec3copy(Vec3 a,Vec3 b){
  a.x=b.x;
  a.y=b.y;
  a.z=b.z;
}

class Metal extends Material{
  Vec3 albedo;
  float fuzz;
  Metal(Vec3 a,float f){
    albedo=a;
    fuzz=f<1?f:1;
  }
  
  @Override
  boolean scatter(Ray r_in,hit_record rec, Vec3 attenuation, Ray scattered){
    Vec3 reflected=reflect(Vec3.unit_vector(r_in.dir()),rec.normal.copy());
    Vec3copy(scattered.origin,rec.p);
    Vec3copy(scattered.direction,reflected.add(random_in_unit_sphere().mult(fuzz)));
    Vec3copy(attenuation,albedo);
    scattered.time=r_in.time();
    return Vec3.dot(scattered.dir(),rec.normal)>0;
  }

}

class Dielectric extends Material{
  float ir;
  Dielectric(float index_of_refraction){
    ir=index_of_refraction;
  }
  @Override
  boolean scatter(Ray r_in,hit_record rec, Vec3 attenuation, Ray scattered){
    Vec3copy(attenuation,new Vec3(1,1,1));
    float refraction_ratio=rec.front_face?(1.0/ir):ir;
    
    Vec3 unit_direction=Vec3.unit_vector(r_in.dir());
    
    float cos_theda=min(Vec3.dot(unit_direction.mult(-1),rec.normal),1.0);
    float sin_theda=sqrt(1-cos_theda*cos_theda);
    boolean cannot_refract=refraction_ratio*sin_theda>1;
    Vec3 direction=new Vec3(0,0,0);
    if(cannot_refract||reflectance(cos_theda,refraction_ratio)>random(1)){
      direction=reflect(unit_direction,rec.normal);
    }else{
      direction=refract(unit_direction,rec.normal,refraction_ratio);
    }    
    Vec3copy(scattered.origin,rec.p);
    Vec3copy(scattered.direction,direction);
    scattered.time=r_in.time();
    return true;
  }
  
  float reflectance(float cosine,float ref_idx){
    float r0=(1-ref_idx)/(1+ref_idx);
    r0=r0*r0;
    return r0+(1-r0)*pow((1-cosine),5);
  
  }
}

class DiffuseLight extends Material{
  Texture emit;
  DiffuseLight(Texture a){
    emit=a;
  }
  DiffuseLight(Vec3 c){
    emit=new SolidColor(c);
  }
  boolean scatter(Ray r_in,hit_record rec, Vec3 attenuation, Ray scattered){
    return false;
  }
  
  @Override
  Vec3 emitted(float u,float v,Vec3 p){
    return emit.value(u,v,p);
  }
  


}


class Isotropic extends Material{
  Texture albedo;
  Isotropic(Vec3 c){
    albedo=new SolidColor(c);
  }
  Isotropic(Texture a){
    albedo=a;
  }
  
  boolean scatter(Ray r_in,hit_record rec, Vec3 attenuation, Ray scattered){
    scattered=new Ray(rec.p,random_in_unit_sphere(),r_in.time());
    attenuation=albedo.value(rec.u,rec.v,rec.p);
    return true;
  }

}
