clc;
clear functions;

old_dir = cd(fileparts(which(mfilename)));

[~,mexLoaded] = inmem('-completenames');
eval('while mislocked(''ipopt''); munlock(''ipopt''); end;');

disp('---------------------------------------------------------');
CMD = 'mex -largeArrayDims -Isrc ';

if ismac
  %
  % libipopt must be set with:
  % install_name_tool -id "@loader_path/libipopt.3.dylib" libipopt.3.dylib
  %
  IPOPT_HOME = '../Ipopt';
  CMD = [ CMD ...
    '-I' IPOPT_HOME '/include/coin-or ' ...
    '-output bin/osx/ipopt_osx ' ...
    'LDFLAGS=''$LDFLAGS -Wl,-rpath,./ -Lbin/osx -L/usr/local/lib -lipopt'' ' ...
    'CXXFLAGS=''$CXXFLAGS -Wall -O2 -g'' ' ...
  ];
elseif isunix
  IPOPT_HOME = '../Ipopt';
  myCCompiler = mex.getCompilerConfigurations('C','Selected');
  switch myCCompiler.Version
  case {'4','5','6'}
    BIN_DIR = 'bin/linux_3';
    MEX_EXE = 'bin/linux_3/ipopt_linux_3';
  case {'7','8'}
    BIN_DIR = 'bin/linux_4';
    MEX_EXE = 'bin/linux_4/ipopt_linux_4';
  otherwise
    BIN_DIR = 'bin/linux_5';
    MEX_EXE = 'bin/linux_5/ipopt_linux_5';
  end
  CMD = [ CMD ...
    '-I' IPOPT_HOME '/include/coin-or ' ...
    '-DOS_LINUX -output ' MEX_EXE ' '...
    'CXXFLAGS=''$CXXFLAGS -Wall -O2 -g'' ' ...
    'LDFLAGS=''$LDFLAGS -static-libgcc -static-libstdc++'' ' ...
    'LINKLIBS=''-L' BIN_DIR ' -L$MATLABROOT/bin/$ARCH -Wl,-rpath,$MATLABROOT/bin/$ARCH ' ...
              '-Wl,-rpath,. -lipopt -lcoinmumps -lopenblas -lgfortran -lgomp -ldl ' ...
              '-lMatlabDataArray -lmx -lmex -lmat -lm '' ' ...
  ];
elseif ispc
  IPOPT_HOME = '../Ipopt';
  CMD = [ CMD ...
    '-I' IPOPT_HOME '/include/coin-or ' ...
    '-output bin/windows/ipopt_win ' ...
    IPOPT_HOME '/lib/ipopt.dll.lib ' ...
  ];
else
  error('architecture not supported');
end

CMD = [ CMD, './src/ipopt.cc ./src/IpoptInterfaceCommon.cc ' ];

disp(CMD);
eval(CMD);

cd(old_dir);

disp('----------------------- DONE ----------------------------');
