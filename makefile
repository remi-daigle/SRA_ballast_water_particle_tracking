all: clean Particle_tracking.o trans.x make.o read_track.x loop
	@echo "EVERYTHING WORKED!"
 
loop: 
	while read -r line; do\
		while read -r yr1 m1 d1 yr2 m2 d2 h1 min1 s1 swim sv Kdiff behav uzl lzl modelrez; do\
			fn=$$(sed 's/ /_/g' <<< "$$yr1 $$m1 $$d1 $$swim $$sv $$Kdiff $$behav $$uzl $$lzl");\
		done <<< $$line;\
		echo $$line > "Run/bp/1_"$$fn;\
		echo $$(sed 's/ /_/g' <<< $$line) > "Run/bp/2_"$$fn;\
		echo $$fn > "Run/bp/3_"$$fn;\
		cp ../tmp/quickstart/template.job ../tmp/quickstart/particles_$$fn.job;\
		sed -i "s/template/$$fn/g" ../tmp/quickstart/particles_$$fn.job;\
		Rscript submit.R $$fn;\
	done < track/behav_table;\
	jobsub ~/tmp/quickstart/verify.job
 
Particle_tracking.o: divers/util.f model/traj3.F90 model/gasdev3.F90 model/update2.F90 model/zeros.F90 model/Particle_tracking.F90
	. ssmuse-sh -x main/opt/intelcomp/intelcomp-2013sp1u2;\
	. ssmuse-sh -x main/opt/openmpi/openmpi-1.6.5/intelcomp-2013sp1u2/;\
	mpif90 divers/util.f model/traj3.F90 model/update2.F90 model/zeros.F90 model/Particle_tracking.F90 -o Run/Particle_tracking.o -I/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/include -L/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/lib -lnetcdf
 
trans.x:
	. ssmuse-sh -x main/opt/intelcomp/intelcomp-2013sp1u2;\
	. ssmuse-sh -x main/opt/openmpi/openmpi-1.6.5/intelcomp-2013sp1u2/;\
	mpif90 Grid/OPA_GET_XY_LL.F90 Grid/ll_to_xy_NEMO.F90 track/trans_ll_to_xy.f -o track/trans.x -I/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/include -L/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/lib -lnetcdf -lnetcdff  -L/usr/local/include/;\
	./track/trans.x
 
make.o:  Run/make_input.f
	. ssmuse-sh -x main/opt/intelcomp/intelcomp-2013sp1u2;\
	. ssmuse-sh -x main/opt/openmpi/openmpi-1.6.5/intelcomp-2013sp1u2/;\
	mpif90 Run/make_input.f -o Run/make.o;\
	#./Run/make.o $$(cat Run/bp/behav_param3)
 
submit: Particle_tracking.o
	Run/Particle_tracking.o $$(cat Run/bp/behav_param3)

read_track.x: track/read_track.f
	# Intel compiler
	. ssmuse-sh -x main/opt/intelcomp/intelcomp-2013sp1u2
	# open MPI-Intel
	. ssmuse-sh -x main/opt/openmpi/openmpi-1.6.5/intelcomp-2013sp1u2/
	#rm -rf track/tmp/*
	mpif90 Grid/OPA_GET_XY_LL.F90 Grid/ll_to_xy_NEMO.F90 divers/util.f track/read_track.f -o track/read_track.x -I/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/include -L/fs/hnas1-evs1/Ddfo/dfo_odis/joc001/netcdf/lib -lnetcdf -lnetcdff  -L/usr/local/include/
	#mkdir track/tmp/$$(cat Run/bp/behav_param2)
	#./track/read_track.x $$(cat Run/bp/behav_param3)

verify:
	#runs="`wc -l < track/behav_table`";\
	#while [[ $$runs -gt 0 ]] ; do\
	#	echo 'verifying runs...';\
	#	Rscript verify.R;\
	#	runs="`wc -l < track/behav_table`";\
	#done
	Rscript verify.R;

zip:
	_now=$$(date +"%m_%d_%Y");\
	_file="output_$$_now.tar.gz";\
	tar -zcf $$_file /fs/isi-nas1/dfo/bioios/dfo_bioios/dar002/OUTPUT/2009_1_1_2009_7_20_0_0_0_1_0.05_25_n_0_100_h/ ;\

clean:
	cp track/behav_table_all track/behav_table
	rm -rf Run/bp/*;\
	rm -rf Run/jobs/*;\
	rm -rf /fs/isi-nas1/dfo/bioios/dfo_bioios/dar002/OUTPUT/*;\
	rm -rf Run/IN/*;\
	rm -rf /fs/isi-nas1/dfo/bioios/dfo_bioios/dar002/RAW/*;\
	rm -rf ~/tmp/quickstart/particles_*;\
	rm -f model/Particle_tracking.o;\
	rm -f track/trans.x;\
	rm -f Run/make.o;\
	rm -f track/read_track.x