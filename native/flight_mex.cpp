#include "mex.h"
#include "flight_core.hpp"
#include <cstring>
static double get(const mxArray* p,const char* group,const char* key) {
    const mxArray* g=mxGetField(p,0,group); const mxArray* v=g?mxGetField(g,0,key):nullptr;
    if(!v || !mxIsDouble(v) || mxIsComplex(v) || mxGetNumberOfElements(v)!=1)
        mexErrMsgIdAndTxt("landing:NativeConfig","Missing numeric configuration field.");
    return mxGetScalar(v);
}
static flight::Config config(const mxArray* p) {
#define F(g,k) get(p,#g,#k)
    return {F(aircraft,mass),F(aircraft,wingArea),F(aircraft,cd0),F(aircraft,inducedDrag),F(aircraft,clMax),F(aircraft,maxThrust),
        F(environment,rho),F(environment,g),F(environment,wind),F(approach,glideAngle),F(approach,speed),F(flare,height),F(flare,speed),F(flare,sinkTarget),
        F(control,pathTimeConstant),F(control,speedTimeConstant),F(ground,brakeMu),F(ground,rollingMu),F(ground,brakeDelay),F(ground,brakeRamp),
        F(ground,residualCL),F(ground,liftDecayTime),F(ground,reverseForce),F(ground,reverseDelay),F(ground,reverseRamp),F(ground,reverseFadeSpeed)};
#undef F
}
static mxArray* vector(const double* v,size_t n) { mxArray* a=mxCreateDoubleMatrix(n,1,mxREAL); std::memcpy(mxGetPr(a),v,n*sizeof(double)); return a; }
static mxArray* fields(const char** names,const double* values,size_t n) {
    mxArray* a=mxCreateStructMatrix(1,1,int(n),names);
    for(size_t i=0;i<n;++i) mxSetFieldByNumber(a,0,int(i),mxCreateDoubleScalar(values[i])); return a;
}
void mexFunction(int nlhs,mxArray* plhs[],int nrhs,const mxArray* prhs[]) {
    if(nrhs!=5 || nlhs<1 || nlhs>2 || !mxIsChar(prhs[0]) || !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || !mxIsStruct(prhs[2]))
        mexErrMsgIdAndTxt("landing:NativeInput","Use [dy,f]=flight_mex(mode,state,config,time,phaseOrCL).");
    char mode[16]; mxGetString(prhs[0],mode,sizeof(mode)); auto p=config(prhs[2]); const double* y=mxGetPr(prhs[1]);
    if(std::strcmp(mode,"air")==0 && mxGetNumberOfElements(prhs[1])==4) {
        auto a=flight::air(p,y,mxGetScalar(prhs[4])!=0); double dy[]={a.dx,a.dh,a.dv,a.dgamma}; plhs[0]=vector(dy,4);
        if(nlhs>1) { const char* n[]={"cl","lift","drag","thrust","speedRef","gammaRef","saturated"}; double v[]={a.cl,a.lift,a.drag,a.thrust,a.speedRef,a.gammaRef,double(a.saturated)}; plhs[1]=fields(n,v,7); }
    } else if(std::strcmp(mode,"ground")==0 && mxGetNumberOfElements(prhs[1])==2) {
        auto a=flight::ground(p,y,mxGetScalar(prhs[3]),mxGetScalar(prhs[4])); double dy[]={a.dx,a.du}; plhs[0]=vector(dy,2);
        if(nlhs>1) { const char* n[]={"cl","lift","drag","normal","brake","rolling","reverse","deceleration"}; double v[]={a.cl,a.lift,a.drag,a.normal,a.brake,a.rolling,a.reverse,a.deceleration}; plhs[1]=fields(n,v,8); }
    } else mexErrMsgIdAndTxt("landing:NativeInput","Mode or state size invalid.");
}
