all:
	echo "this works"
 
particle_tracking: divers/util.f model/traj3.F90 model/update2.F90 model/zeros.F90 model/Particle_tracking.F90
	mpif90 divers/util.f model/traj3.F90 model/update2.F90 model/zeros.F90 model/Particle_tracking.F90 -o Run/Particle_tracking.o -I/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/include -L/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/lib -lnetcdf
 
trans:
	mpif90 Grid/OPA_GET_XY_LL.F90 Grid/ll_to_xy_NEMO.F90 track/trans_ll_to_xy.f -o track/trans.x -I/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/include -L/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/lib -lnetcdf -lnetcdff  -L/usr/local/include/