import java.util.*;

float ratio=(float)9/(float)9;
float img_width=800;
int max_depth=50;
int samples_per_pixel=10;
int type=1;

int count=0;

float img_height=img_width/ratio;
float viewport_height=2;
float viewport_width=ratio*viewport_height;
float focal_length=1;
float INFINITY=1.0/0.0;

Vec3 lookfrom=new Vec3(13,2,3);
Vec3 lookat=new Vec3(0,0,0);
Vec3 vup=new Vec3(0,1,0);
float dist_to_focus=(10);
float aperture=0.1;

hittable_list world;

Camera camera;
int frameC=0;

Vec3 origin;
Vec3 horizontal;
Vec3 vertical;
Vec3 lower_left_corner;
Vec3 backgroundColor=new Vec3(0,0,0);
String startTime;

void settings() {
  size((int)img_width, (int)img_height,P2D);
  //camera=new Camera();
}
void setup() {
  startTime=(year() + "年" + month() +"月" + day() +"日"+hour()+":"+minute()+":"+second());
  float vfov = 40.0;
  float aperture = 0.0;
  
  //world.add(new Sphere(new Vec3(-R,0,-1),R,ml));
  //world.add(new Sphere(new Vec3(R,0,-1),R,mr));
  switch(type){
    case 1:
      world=random_scene();
      backgroundColor=new Vec3(0.7,0.8,1.0);
      lookfrom =new Vec3(13,2,3);
      lookat =new Vec3(0,0,0);
      vfov = 20.0;
      aperture = 0.1;
      break;
    case 2:
      world = two_spheres();
      backgroundColor=new Vec3(0.7,0.8,1.0);
      lookfrom = new Vec3(13,2,3);
      lookat = new Vec3(0,0,0);
      vfov = 20.0;
      break;    
    case 3:
      world=earth();
      backgroundColor=new Vec3(0.7,0.8,1.0);
      lookfrom = new Vec3(13,2,3);
      lookat = new Vec3(0,0,0);
      vfov = 20.0;
      break;
    
    case 4:
      world=simpleLight();
      backgroundColor=new Vec3(0,0,0);
      lookfrom = new Vec3(26,3,6);
      lookat = new Vec3(0,0,0);
      vfov = 20.0;      
      break;
    case 5:
      world=cornellBox();
      //aperture = 1.0;            
      backgroundColor =new Vec3(0,0,0);
      lookfrom =new Vec3(278, 278, -750);
      lookat =new Vec3(278, 278, 0);
      vfov = 40.0;
      break;
   
    case 6:
      world=cornellBoxSmoke();
      //aperture = 1.0;            
      backgroundColor =new Vec3(0,0,0);
      lookfrom =new Vec3(278, 278, -750);
      lookat =new Vec3(278, 278, 0);
      vfov = 40.0;
      break;
    
    case 7:
      world=finalScene();
      //aperture = 1.0;            
      backgroundColor =new Vec3(0,0,0);
      lookfrom =new Vec3(478, 278, -600);
      lookat =new Vec3(278, 278, 0);
      vfov = 40.0;
      break;
    default:
    case 8:
      world=twoPerlinSphere();
      //aperture = 1.0;            
      
      lookfrom =new Vec3(13, 2, 3);
      lookat =new Vec3(0, 0, 0);
      vfov = 20.0;
      break;
    
  }
    
   camera=new Camera(lookfrom,lookat,vup,vfov,ratio,aperture,dist_to_focus,0,1);
  
  
  //world.add(new Sphere(new Vec3(1,0,-1),0.2));
  //world.add(new Sphere(new Vec3(-1,0,-1),0.1));
}
void draw() {
  //background(255);
  
  move();

  //world

  //camera

  //Render
  colorful();
  //println(frameC++);
  saveFrame("rayTracing.png");
  println(startTime);
  println((year() + "年" + month() +"月" + day() +"日"+hour()+":"+minute()+":"+second()));
  noLoop();
}

void colorful() {
  loadPixels();
  float c=0;
  for (int j=0; j<height; j+=1) {
    for (int i=0; i<width; i+=1) {
     if(c%640==0)println(c*100/(width*height)+"%");c+=1;
      Vec3 pixel_color=new Vec3(0, 0, 0);
      int index=(height-j-1)*width+i;
      for (int s=0; s<samples_per_pixel; s+=1) {        
        float u=map(float(i)+random(1), 0, width, 0, 1);
        float v=map(float(j)+random(1), 0, height, 0, 1);
        Ray r=camera.get_ray(u, v);
        pixel_color=Vec3.add(pixel_color, ray_color(r,backgroundColor ,world, max_depth));
      }
      Vec3 wr=write_color(pixel_color, samples_per_pixel);
      
      int pixel=pixels[index];
    
      int B_MASK = 255;
      int G_MASK = 255<<8; //65280 
      int R_MASK = 255<<16; //16711680

      float r = (pixel & R_MASK)>>16;
      float g = (pixel & G_MASK)>>8;
      float b = pixel & B_MASK;
       pixels[index]=color((clamp(wr.x(), 0.0, 0.999)*255),
                          (clamp(wr.y(), 0.0, 0.999)*255), 
                          (clamp(wr.z(), 0.0, 0.999)*255));
      //pixels[index]=color((r*frameC+clamp(wr.x(), 0.0, 0.999)*255)/(frameC+1),
      //                    (g*frameC+clamp(wr.y(), 0.0, 0.999)*255)/(frameC+1), 
      //                    (b*frameC+clamp(wr.z(), 0.0, 0.999)*255)/(frameC+1));
    }
  }
  updatePixels();
  println("DONE");
}

Vec3 ray_color(Ray r,Vec3 backgroundColor ,Hittable world, int depth) {
  hit_record rec=new hit_record();
  if (depth<=0) {
    return new Vec3(0, 0, 0);
  }
  
  if(!world.hit(r, 0.001, INFINITY, rec)){
    return backgroundColor;
  }  
     
  Ray scattered=new Ray(new Vec3(0,0,0),new Vec3(0,0,0),0);
  Vec3 attenuation=new Vec3(0,0,0);
  Vec3 emitted=rec.mat_ptr.emitted(rec.u,rec.v,rec.p);
  if(!rec.mat_ptr.scatter(r,rec,attenuation,scattered)){
    //attenuation.sprintln();
    return emitted;      
  }    
  return Vec3.add(emitted ,attenuation.inner_product(ray_color(scattered,backgroundColor,world,depth-1)));
    //return new Vec3(0,0,0);
    
    //Vec3 target =rec.p.add(rec.normal).add(random_unit_vector());
    ////return rec.normal.add(new Vec3(1, 1, 1));
    //return ray_color(new Ray(rec.p,target.sub(rec.p)),world,depth-1).mult(0.5);
  

  //Vec3 unit_direction=Vec3.unit_vector(r.dir());
  //float t=0.5*(unit_direction.y()+1.0);
  //return Vec3.add(Vec3.mult(1-t, new Vec3(1, 1, 1)), Vec3.mult(t, new Vec3(0.5, 0.7, 1)));
}


float hit_sphere(Vec3 center, float radius, Ray r) {
  Vec3 oc=r.orig().sub(center);
  float a=Vec3.dot(r.dir(), r.dir());
  float half_b=Vec3.dot(oc, r.dir());
  float c=Vec3.dot(oc, oc)-radius*radius;
  float discriminant=half_b*half_b-a*c;
  if (discriminant<0) return -1.0;
  else return (float)(-half_b-sqrt(discriminant))/(float)(a);
}

void move() {
  if (keyPressed) {
    if (key=='w'||key=='W') {
      camera.origin.z-=0.01;
    }
    if (key=='s'||key=='S') {
      camera.origin.z+=0.01;
    }
  }
}
float degree_to_radians(float degrees) {
  return degrees*PI/180;
}
float clamp(float x, float min, float max) {
  if (x < min) return min;
  if (x > max) return max;
  return x;
}
Vec3 write_color(Vec3 pixel_color, int sample_per_pixel) {
  float r=pixel_color.x();
  float g=pixel_color.y();
  float b=pixel_color.z();

  float scale=1.0/(float)sample_per_pixel;
  r=sqrt(scale*r);
  g=sqrt(scale*g);
  b=sqrt(scale*b);
  return new Vec3(r, g, b);
}
float random_float() {
  return random(1);
}

hittable_list twoPerlinSphere(){
  hittable_list world=new hittable_list();
  Texture pertext=new NoiseTexture(4);
  world.add(new Sphere(new Vec3(0,-1000,0),-1000,new Lambertian(pertext)));
  world.add(new Sphere(new Vec3(0,2,0),2,new Lambertian(pertext)));
  
  return world;
}

hittable_list finalScene(){
  hittable_list world=new hittable_list();
  
  hittable_list boxes1=new hittable_list();
  Material ground=new Lambertian(new Vec3(0.48,0.83,0.53));
  int boxesPerSide=20;
  for(int i=0;i<boxesPerSide;i+=1){
    for(int j=0;j<boxesPerSide;j+=1){
      float w=100.0;
      float x0=-1000.0+i*w;
      float z0=-1000.0+j*w;
      float y0=0.0;
      float x1=x0+w;
      float y1=random(1,101);
      float z1=z0+w;
      //println(x0,y0,z0,x1,y1,z1);
      boxes1.add(new Box(new Vec3(x0,y0,z0),new Vec3(x1,y1,z1),ground));
    }
  }
  
  world.add(new BVHNode(boxes1.objects,0,boxes1.objects.size()-1,0,1));
  world.add(new XyRect(-1000,1000,-1000,1000,1000,ground));
  Material light=new DiffuseLight(new Vec3(7,7,7));
  world.add(new XzRect(123,423,147,412,554,light));
  
  Vec3 center1=new Vec3(400,400,200);
  Vec3 center2=Vec3.add(center1,new Vec3(30,0,0));
  Material movingMaterial=new Lambertian(new Vec3(0.7,0.3,0.1));
  world.add(new MovingSphere(center1,center2,0,1,50,movingMaterial));
  world.add(new Sphere(new Vec3(260,150,45),50,new Dielectric(1.5)));
  world.add(new Sphere(new Vec3(0,150,145),50,new Metal(new Vec3(0.8,0.8,0.9),1.0)));
  Hittable boundary=new Sphere(new Vec3(360,150,145),70,new Dielectric(1.5));
  world.add(boundary);
  //world.add(new ConstantMedium(boundary,0.2,new Vec3(0.2,0.4,0.9)));
  Hittable boundary1=new Sphere(new Vec3(0,0,0),5000,new Dielectric(1.5));
  //world.add(new ConstantMedium(boundary1,0.0001,new Vec3(1,1,1)));
  
  Material emat=new Lambertian(new ImageTexture("earthmap.jpg"));
  world.add(new Sphere(new Vec3(400,200,400),100,emat));
  Texture pertext=new NoiseTexture(0.1);
  //world.add(new Sphere(new Vec3(220,280,300),80,new Lambertian(pertext)));
  
  Material white=new Lambertian(new Vec3(0.73,0.73,0.73));
  hittable_list boxes2=new hittable_list();
  
  
  int ns=1000;
  for(int j=0;j<ns;j+=1){
    boxes2.add(new Sphere(new Vec3(random(0,165),random(0,165),random(0,165)),10,white));  
  }
  world.add(new Translate(new RotateY(new BVHNode(boxes2.objects,0,boxes2.objects.size()-1,0.0,1.0),15),new Vec3(-100,270,395)));
  
  return world; 
}

hittable_list cornellBoxSmoke(){
  hittable_list world=new hittable_list();
  
  Material red=new Lambertian(new Vec3(0.65,0.05,0.05));
  Material green=new Lambertian(new Vec3(0.12,0.45,0.15));
  Material white=new Lambertian(new Vec3(0.73,0.73,0.73));
  Material light=new DiffuseLight(new Vec3(7,7,7));
  
  world.add(new YzRect(0,555,0,555,555,green));
  world.add(new YzRect(0,555,0,555,0,red));
  world.add(new XzRect(148, 408, 162, 397, 554,light));
  world.add(new XzRect(0,555,0,555,0,white));
  world.add(new XzRect(0,555,0,555,555,white));
  world.add(new XyRect(0,555,0,555,555,white));
  
  Hittable box1=new Box(new Vec3(0,0,0),new Vec3(165,330,165),white);
  box1=new RotateY(box1,15);
  box1=new Translate(box1,new Vec3(265,0,295));
  world.add(new ConstantMedium(box1,0.01,new Vec3(0,0,0)));
  
  Hittable box2=new Box(new Vec3(0,0,0),new Vec3(165,165,165),white);
  box2=new RotateY(box2,-18);
  box2=new Translate(box2,new Vec3(130,0,65));
  world.add(new ConstantMedium(box2,0.01,new Vec3(1,1,1)));
  
  
  return world; 
}


hittable_list cornellBox(){
  hittable_list world=new hittable_list();
  
  Material red=new Lambertian(new Vec3(0.65,0.05,0.05));
  Material green=new Lambertian(new Vec3(0.12,0.45,0.15));
  Material white=new Lambertian(new Vec3(0.73,0.73,0.73));
  Material light=new DiffuseLight(new Vec3(15,15,15));
  
  world.add(new YzRect(0,555,0,555,555,green));
  world.add(new YzRect(0,555,0,555,0,red));
  world.add(new XzRect(148, 408, 162, 397, 554,light));
  world.add(new XzRect(0,555,0,555,0,white));
  world.add(new XzRect(0,555,0,555,555,white));
  world.add(new XyRect(0,555,0,555,555,white));
  
  Hittable box1=new Box(new Vec3(0,0,0),new Vec3(165,330,165),white);
  box1=new RotateY(box1,15);
  box1=new Translate(box1,new Vec3(265,0,295));
  world.add(box1);
  
  Hittable box2=new Box(new Vec3(0,0,0),new Vec3(165,165,165),white);
  box2=new RotateY(box2,-18);
  box2=new Translate(box2,new Vec3(130,0,65));
  world.add(box2);
  
  
  return world; 
}
hittable_list simpleLight(){
  hittable_list world=new hittable_list();
  Texture ct=new CheckerTexture(new Vec3(0.5,0.1,0.6),new Vec3(0.8,0.8,0.9));
  world.add(new Sphere(new Vec3(0,-1000,0),1000,new Lambertian(ct)));
  world.add(new Sphere(new Vec3(0,2,0),2,new Lambertian(ct)));
  Material difflight=new DiffuseLight(new Vec3(4,4,4));
  world.add(new Sphere(new Vec3(0,7,0),2,difflight));
  return world;
}

hittable_list earth(){
  hittable_list world=new hittable_list();
  Texture earthTexture=new ImageTexture("earthmap.jpg");
  Material earthSurface=new Lambertian(earthTexture);
  Hittable globe=new Sphere(new Vec3(0,0,0),2,earthSurface);
  world.add(globe);
  
  return world;
}

hittable_list two_spheres(){
  hittable_list world=new hittable_list();
  Texture checker=new CheckerTexture(new Vec3(0.2,0.3,0.1),new Vec3(0.9,0.9,0.9));
  Lambertian ground_material=new Lambertian(checker);
  world.add(new Sphere(new Vec3(0,-10,0),10,ground_material));
  world.add(new Sphere(new Vec3(0,10,0),10,ground_material));

  return world;
}
hittable_list random_scene(){
  hittable_list world=new hittable_list();
  Texture checker=new CheckerTexture(new Vec3(0.2,0.3,0.1),new Vec3(0.9,0.9,0.9));
  Lambertian ground_material=new Lambertian(checker);
  world.add(new Sphere(new Vec3(0,-1000,0),1000,ground_material));
  
  for(int a=-10;a<10;a+=1){
    for(int b=-10;b<10;b+=1){
      
      float choose_mat=random(1);
      Vec3 center=new Vec3(a+0.9*random(1),0.2,b+0.9*random(1));
      
      if(center.sub(new Vec3(4,0.2,0)).length()>0.9){
        Material sphere_material;
        if(choose_mat<0.6){
          Vec3 albedo=vec_random().inner_product(vec_random());
          sphere_material=new Lambertian(albedo);
          world.add(new Sphere(center,0.2,sphere_material));
          
          Vec3 center2=center.add(new Vec3(0,random(0,0.5),0));
          //world.add(new MovingSphere(center,center2,0,1,0.2,sphere_material));
          
        }
        else if(choose_mat<0.8){
          Vec3 albedo=vec_random(0.5,1);
          float fuzz=random(0,0.5);
          sphere_material=new Metal(albedo,fuzz);
          world.add(new Sphere(center,0.2,sphere_material));
        }
        else{
          sphere_material=new Dielectric(1.5);
          world.add(new Sphere(center,0.2,sphere_material));
        }        
      }
    }
  }
  Material material1=new Dielectric(1.5);
  world.add(new Sphere(new Vec3(0,1,0),1.0,material1));
  Material material2=new Lambertian(new Vec3(0.4,0.2,0.1));
  world.add(new Sphere(new Vec3(-4,1,0),1.0,material2));
  Material material3=new Metal(new Vec3(0.7,0.6,0.5),0);
  world.add(new Sphere(new Vec3(4,1,0),1.0,material3));

  return world;
}
