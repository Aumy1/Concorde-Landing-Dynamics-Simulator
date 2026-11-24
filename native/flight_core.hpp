#pragma once
#include <algorithm>
#include <cmath>
namespace flight {
struct Config {
    double mass, area, cd0, induced, clMax, maxThrust, rho, g, wind;
    double glide, approachSpeed, flareHeight, flareSpeed, sink, pathTau, speedTau;
    double brakeMu, rollingMu, brakeDelay, brakeRamp, residualCL, liftTau;
    double reverseForce, reverseDelay, reverseRamp, reverseFade;
};
struct Air { double dx,dh,dv,dgamma,cl,lift,drag,thrust,speedRef,gammaRef; bool saturated; };
struct Ground { double dx,du,cl,lift,drag,normal,brake,rolling,reverse,deceleration; };
inline double unit(double x) { return std::clamp(x,0.,1.); }
inline Air air(const Config& p,const double* y,bool flare) {
    const double v=std::max(y[2],1.), gamma=y[3];
    double speedRef=p.approachSpeed, gammaRef=-p.glide;
    if(flare) {
        const double f=unit(y[1]/p.flareHeight);
        const double sinkRef=p.sink+(p.approachSpeed*std::sin(p.glide)-p.sink)*f;
        gammaRef=-std::asin(std::min(sinkRef/v,.9));
        speedRef=p.flareSpeed+(p.approachSpeed-p.flareSpeed)*f;
    }
    const double qs=.5*p.rho*v*v*p.area;
    const double clReq=p.mass*(v*(gammaRef-gamma)/p.pathTau+p.g*std::cos(gamma))/qs;
    const double cl=std::clamp(clReq,0.,p.clMax);
    const double lift=qs*cl, drag=qs*(p.cd0+p.induced*cl*cl);
    const double tr=drag+p.mass*p.g*std::sin(gamma)+p.mass*(speedRef-v)/p.speedTau;
    const double thrust=std::clamp(tr,0.,p.maxThrust);
    return {v*std::cos(gamma)+p.wind,v*std::sin(gamma),(thrust-drag)/p.mass-p.g*std::sin(gamma),
        lift/(p.mass*v)-p.g*std::cos(gamma)/v,cl,lift,drag,thrust,speedRef,gammaRef,
        std::abs(clReq-cl)>1e-10 || std::abs(tr-thrust)>1e-6};
}
inline Ground ground(const Config& p,const double* y,double t,double tdCL) {
    const double u=std::max(y[1],0.), v=std::max(u-p.wind,0.);
    const double cl=p.residualCL+(tdCL-p.residualCL)*std::exp(-std::max(t,0.)/p.liftTau);
    const double qs=.5*p.rho*v*v*p.area;
    const double lift=qs*cl, drag=qs*(p.cd0+p.induced*cl*cl), normal=std::max(p.mass*p.g-lift,0.);
    const double brake=p.brakeMu*unit((t-p.brakeDelay)/p.brakeRamp)*normal;
    const double rolling=p.rollingMu*normal;
    const double reverse=p.reverseForce*unit((t-p.reverseDelay)/p.reverseRamp)*std::min(u/p.reverseFade,1.);
    const double dec=(drag+brake+rolling+reverse)/p.mass;
    return {u,-dec,cl,lift,drag,normal,brake,rolling,reverse,dec};
}
}
