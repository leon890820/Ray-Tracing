class Perlin {
  int pointCount=256;

  int[] perm_x;
  int[] perm_y;
  int[] perm_z;
  Vec3[] ranvec;

  Perlin() {
    ranvec=new Vec3[pointCount];
    
    for (int i=0; i<pointCount; i+=1) {
      ranvec[i]=new Vec3(random(-1,1),random(-1,1),random(-1,1));
    }
    perm_x=perlinGeneratePerm();
    perm_y=perlinGeneratePerm();
    perm_z=perlinGeneratePerm();
  }
  
  float turb(Vec3 p,int depth){
    float accum=0;
    Vec3 temp_p=p;
    float weight=1;
    for(int i=0;i<depth;i+=1){
      accum+=weight*perlinNoise(temp_p);
      weight*=0.5;
      temp_p=temp_p.mult(2);
    }
    return abs(accum);
  }

  int[] perlinGeneratePerm() {
    int[] p=new int[pointCount];
    for (int i=0; i<pointCount; i+=1) {
      p[i]=i;
    }
    permute(p, pointCount);
    return p;
  }

  float perlinNoise(Vec3 p) {
    float u=p.x()-floor(p.x());
    float v=p.y()-floor(p.y());
    float w=p.z()-floor(p.z());

    
    int i=floor(p.x());
    int j=floor(p.y());
    int k=floor(p.z());
    Vec3[][][] c=new Vec3[2][2][2];
    for (int di=0; di<2; di+=1) {
      for (int dj=0; dj<2; dj+=1) {
        for (int dk=0; dk<2; dk+=1) {
          c[di][dj][dk]=ranvec[perm_x[(i+di)&255]^perm_y[(j+dj)&255]^perm_z[(k+dk)&255]];
        }
      }
    }
    return perlinInterp(c, u, v, w);
  }

  float perlinInterp(Vec3[][][] c, float u, float v, float w) {
    float accum = 0.0;
    float uu=u*u*(3-2*u);
    float vv=v*v*(3-2*v);
    float ww=w*w*(3-2*w);
    for (int i=0; i < 2; i++) {
      for (int j=0; j < 2; j++) {
        for (int k=0; k < 2; k++) {
          Vec3 weightV=new Vec3(u-i,v-j,w-k);
          accum += (i*uu + (1-i)*(1-uu))*(j*vv + (1-j)*(1-vv))*(k*ww + (1-k)*(1-ww))*Vec3.dot(c[i][j][k],weightV);
        }
      }
    }
    return accum;
  }

  void permute(int[] p, int n) {
    for (int i=n-1; i>0; i-=1) {
      int target=(int)random(0, i+1);
      int tmp=p[i];
      p[i]=p[target];
      p[target]=tmp;
    }
  }
}
