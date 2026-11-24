#include "flight_core.hpp"
#include <cassert>
#include <iostream>
int main() {
    flight::Config p{190000,443,.055,.075,2.5,420000,1.225,9.80665,0,.05235987756,75,12,72,.7,.65,4,.30,.015,1.5,1,.15,1,110000,1,1.5,25};
    double y[]={-1000,100,75,-p.glide}; auto a=flight::air(p,y,false);
    assert(std::abs(a.dv)<1e-10 && std::abs(a.dgamma)<1e-10 && a.dh<0);
    y[1]=0; auto f=flight::air(p,y,true); assert(f.gammaRef>a.gammaRef && f.cl>a.cl);
    double g[]={100,72}; auto b=flight::ground(p,g,8,a.cl);
    assert(b.du<0 && b.brake>0 && b.reverse>0 && b.normal>0);
    g[1]=0; assert(flight::ground(p,g,8,a.cl).reverse==0);
    std::cout<<"PASS: C++ air, flare, braking, reverse fade\n";
}
