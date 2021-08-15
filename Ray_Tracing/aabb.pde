class AABB{
  Vec3 minimum;
  Vec3 maximum;
  AABB(){}
  AABB(Vec3 a,Vec3 b){
    minimum=a;
    maximum=b;
  }
  
  Vec3 mini(){
    return minimum;
  }
  Vec3 maxi() {
    return maximum;
  }
  
  boolean hit(Ray r,float t_min,float t_max){
    for(int i=0;i<3;i+=1){
      float invD=1.0/r.dir().xyz(i);
      float t0=(mini().xyz(i)-r.orig().xyz(i))*invD;
      float t1=(maxi().xyz(i)-r.orig().xyz(i))*invD;
      if(invD<0){
        float temp;
        temp=t0;
        t0=t1;
        t1=temp;
      }
      t_min=t0>t_min?t0:t_min;
      t_max=t1<t_max?t1:t_max;
      if(t_max<=t_min) return false;
    }
    
    
    return true;
    
    
  }




}
