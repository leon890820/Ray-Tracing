abstract class Texture{
  abstract Vec3 value(float u,float v,Vec3 p);

}


class SolidColor extends Texture{
  Vec3 colorValue;
  SolidColor(Vec3 c){
    colorValue=c;
  }
  SolidColor(float r,float g,float b){
    colorValue=new Vec3(r,g,b);
  }
  
  @Override
  Vec3 value(float u,float v,Vec3 p){
    return colorValue;
  }
}

class CheckerTexture extends Texture{
  Texture even;
  Texture odd;
  CheckerTexture(Texture _even,Texture _odd){
    even=_even;
    odd=_odd;
  }
  CheckerTexture(Vec3 c1,Vec3 c2){
    even=new SolidColor(c1);
    odd=new SolidColor(c2);
  }
  
  @Override
  Vec3 value(float u,float v,Vec3 p){
    
    float sines=sin(10*p.x())*sin(10*p.y())*sin(10*p.z());
    if(sines<0) return odd.value(u,v,p);
    else return even.value(u,v,p);
  
  }


}

class NoiseTexture extends Texture{
  Perlin noise=new Perlin();
  float scale;
  NoiseTexture(float sc){
    scale=sc;
  }
  
  @Override
  Vec3 value(float u,float v,Vec3 p){
    return new Vec3(1,1,1).mult(0.5).mult(1+sin(scale*p.z())+10*noise.turb(p.mult(scale),7));
  }

}


class ImageTexture extends Texture{
  int bytesPerPixel=3;
  PImage data;
  int wid,hei;
  int bytesPerScanline;
  ImageTexture(String file){
    data=loadImage(file);
    wid=data.width;
    hei=data.height;
    bytesPerScanline=bytesPerPixel*wid;
  
  }

  @Override
  Vec3 value(float u,float v,Vec3 p){
    if(data==null) return new Vec3(0,1,1);
    
    u =clamp(u,0,1);
    v=1.0-clamp(v,0,1);
    int i=(int)(u*wid);
    int j=(int)(v*hei);
    
    if(i>=wid) i=wid-1;
    if(j>=hei) j=hei-1;
    
    
    float colorScale=1.0/255.0;
    int index=j*wid+i;
    int pixel=data.pixels[index];
    
    int B_MASK = 255;
    int G_MASK = 255<<8; //65280 
    int R_MASK = 255<<16; //16711680


    float r = (pixel & R_MASK)>>16;
    float g = (pixel & G_MASK)>>8;
    float b = pixel & B_MASK;
    
    return new Vec3(r*colorScale,g*colorScale,b*colorScale);
  }

}
