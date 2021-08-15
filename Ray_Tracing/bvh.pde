class BVHNode extends Hittable{
  Hittable left;
  Hittable right;
  AABB box;
  
  
  
  BVHNode(ArrayList srcObjects,int start,int end,float time0,float time1){
    box=new AABB();
    ArrayList<Hittable> objects=srcObjects;
    int axis=(int)random(0,3);
    //boolean comparator=(axis==0)?boxXCompare:(axis==1)?boxYCompare:boxZCompare;
    int objectSpan=end-start;
    if(objectSpan==1){
      left=objects.get(start);
      right=objects.get(start);
    }else if(objectSpan==2){
      int com=0;       
      com=boxCompare(objects.get(start),objects.get(end),axis);
      if(com>0){
        left=objects.get(start);
        right=objects.get(start+1);
      }else{
        left=objects.get(start+1);
        right=objects.get(start);
      }
        
      
      
      
      
    }else{
       if(axis==0) Collections.sort(objects.subList(start,end),hittableCompareX);
       else if(axis==1) Collections.sort(objects.subList(start,end),hittableCompareY);
       else Collections.sort(objects.subList(start,end),hittableCompareZ);
       int mid=start+objectSpan/2;
       left=new BVHNode(objects,start,mid,time0,time1);
       right=new BVHNode(objects,mid,end,time0,time1);
       
    }
    
    AABB boxLeft=new AABB();
    AABB boxRight=new AABB();
    
    if(!left.boundingBox(time0,time1,boxLeft)||!right.boundingBox(time0,time1,boxRight)){
    
    }
    //println(start,end);
    //boxLeft.minimum.print();
    //boxLeft.maximum.print();
    //boxRight.minimum.print();
    //boxRight.maximum.print();
    AABB ob=surroundingBox(boxLeft,boxRight);
    
    copyAABB(box,ob);
    
    //box.minimum.print();
    //box.maximum.print();
    
  }
  
  @Override
  boolean hit(Ray r, float t_min, float t_max, hit_record rec){
    
    
    if(!box.hit(r,t_min,t_max)) return false;
    
    boolean hitLeft=left.hit(r,t_min,t_max,rec);
    boolean hitRight=right.hit(r,t_min,hitLeft?rec.t:t_max,rec);
    return hitLeft||hitRight;
  }
  
  @Override
  boolean boundingBox(float time0,float time1, AABB outputBox){
    copyAABB(outputBox,box);
    return true;
  }



}

int boxCompare(Hittable a,Hittable b,int axis){
  AABB boxA=new AABB();
  AABB boxB=new AABB();
   
  if(!a.boundingBox(0,0,boxA)||!b.boundingBox(0,0,boxB)){
  
  
  }
  
  if(boxA.mini().xyz(axis)<boxB.mini().xyz(axis)) return -1;
  else if(boxA.mini().xyz(axis)>boxB.mini().xyz(axis))return 1;
  else return 0;

}

int boxXCompare(Hittable a,Hittable b){
  return boxCompare(a,b,0);
}
int boxYCompare(Hittable a,Hittable b){
  return boxCompare(a,b,1);
}
int boxZCompare(Hittable a,Hittable b){
  return boxCompare(a,b,2);
}


Comparator<Hittable> hittableCompareX = new Comparator<Hittable>() {
    @Override
    public int compare(Hittable e1, Hittable e2) {
        return boxXCompare(e1,e2);
    }
};

Comparator<Hittable> hittableCompareY = new Comparator<Hittable>() {
    @Override
    public int compare(Hittable e1, Hittable e2) {
        return boxYCompare(e1,e2);
    }
};

Comparator<Hittable> hittableCompareZ = new Comparator<Hittable>() {
    @Override
    public int compare(Hittable e1, Hittable e2) {
        return boxZCompare(e1,e2);
    }
};
