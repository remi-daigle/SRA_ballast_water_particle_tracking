for i in $(eval echo {1..$(wc -l <~/SRA_ballast_water_particle_tracking/track/behav_table)})
#i=1
do
	echo $i
	cd ~/SRA_ballast_water_particle_tracking/Run/
	#create temporary behav_param
	# h=hour,m=minute,s=second,swim = vertical swimming speed (mm/s), sv = SD for "swim", Kdiff = K (diffusion index m/s^2), diel (1 or 0), tidal (1 or 0), uzl=upper depth limit, lzl=lower depth limit, modelrez=h or l
	#     yr1 m1 d1 yr2 m2 d2 h1 m1 s1 swim sv Kdiff behav uzl lzl modelrez
        rm -rf ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param
        rm -rf ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param2
        rm -rf ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param3
	sed -n "${i}p" <~/SRA_ballast_water_particle_tracking/track/behav_table >>~/SRA_ballast_water_particle_tracking/Run/bp/behav_param
#        cp ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param2
	

	#select appropriate ocean.h and parameter.h
	#rm -rf ~/SRA_ballast_water_particle_tracking/model/ocean.h
	#rm -rf ~/SRA_ballast_water_particle_tracking/track/parameter.h
	#rm -rf ~/SRA_ballast_water_particle_tracking/Grid/parameter.h
	while read -r yr1 m1 d1 yr2 m2 d2 h1 min1 s1 swim sv Kdiff behav uzl lzl modelrez
	do
		 if [ $modelrez = 'l' ];then
		    cp ~/SRA_ballast_water_particle_tracking/model/oceanlow.h ~/SRA_ballast_water_particle_tracking/model/ocean.h
		    cp ~/SRA_ballast_water_particle_tracking/track/parameterlow.h ~/SRA_ballast_water_particle_tracking/track/parameter.h
		    cp ~/SRA_ballast_water_particle_tracking/Grid/parameterlow.h ~/SRA_ballast_water_particle_tracking/Grid/parameter.h
		 else
		    cp ~/SRA_ballast_water_particle_tracking/model/oceanhigh.h ~/SRA_ballast_water_particle_tracking/model/ocean.h
		    cp ~/SRA_ballast_water_particle_tracking/track/parameterhigh.h ~/SRA_ballast_water_particle_tracking/track/parameter.h
		    cp ~/SRA_ballast_water_particle_tracking/Grid/parameterhigh.h ~/SRA_ballast_water_particle_tracking/Grid/parameter.h
		 fi
        echo $yr1 $m1 $d1 $swim $sv $Kdiff $behav $uzl $lzl | awk '{$1=$1}1' OFS="_">>~/SRA_ballast_water_particle_tracking/Run/bp/behav_param3
	done < ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param
        s=$(< ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param)
	echo $s | awk '{$1=$1}1' OFS="_">>~/SRA_ballast_water_particle_tracking/Run/bp/behav_param2
#        echo $~/SRA_ballast_water_particle_tracking/Run/bp/behav_param2 | awk '{$1=$1}1' OFS="_">>~/SRA_ballast_water_particle_tracking/Run/bp/behav_param2
        cp ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param3 ~/SRA_ballast_water_particle_tracking/Run/bp/3_$(< ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param3)
        cp ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param ~/SRA_ballast_water_particle_tracking/Run/bp/1_$(< ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param3)
        cp ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param2 ~/SRA_ballast_water_particle_tracking/Run/bp/2_$(< ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param3)
	
	sleep 1

	# compile Particle_tracking.F90
	cd ~/SRA_ballast_water_particle_tracking/model/
	#./compile

	sleep 1 

	cp ~/SRA_ballast_water_particle_tracking/Run/Particle_tracking.o ~/SRA_ballast_water_particle_tracking/Run/Particle_tracking/p$i

	# compile trans.x (transfer part_loc.ll to part_loc.xy)

	

	cd ~/SRA_ballast_water_particle_tracking/track/
	#./compile_trans  #turn this off if not starting with lat/long

	sleep 1

	# compile the input maker (part_loc.xy to input_particles) 
	cd ~/SRA_ballast_water_particle_tracking/Run/
	#./compile_make

	sleep 5
 
	#run the model
	f=$(< ~/SRA_ballast_water_particle_tracking/Run/bp/behav_param3)
        #~/SRA_ballast_water_particle_tracking/Run/Particle_tracking/p$i $f

		#if [ $i = $(wc -l <~/SRA_ballast_water_particle_tracking/track/behav_table) ]; then
		   #qsub -cwd -l h_rt=23:55:0 -v i=$i,f=$f -m e -M daigleremi@gmail.com ../treatment_run.sh
		#else
		   #qsub -cwd -l h_rt=23:55:0 -v i=$i,f=$f ../treatment_run.sh
		#fi
        

        
	sleep 2

done
