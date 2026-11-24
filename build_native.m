function build_native()
%BUILD_NATIVE Compile C++17 dynamics as a MATLAB MEX module.
root = fileparts(mfilename('fullpath'));
if ispc
    mex('-R2018a','COMPFLAGS=$COMPFLAGS /std:c++17','-outdir',root,fullfile(root,'native','flight_mex.cpp'));
else
    mex('-R2018a','CXXFLAGS=$CXXFLAGS -std=c++17','-outdir',root,fullfile(root,'native','flight_mex.cpp'));
end
rehash;
disp('C++ backend built. Simulations now use native dynamics.');
end
