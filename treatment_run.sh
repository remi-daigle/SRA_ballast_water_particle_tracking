. ssmuse-sh -x main/opt/intelcomp/intelcomp-2013sp1u2
. ssmuse-sh -x main/opt/openmpi/openmpi-1.6.5/intelcomp-2013sp1u2/
pwd
echo 'Making input for '$1
Run/make.o $1
echo 'Running particle tracking for '$1
Run/Particle_tracking.o $1
echo 'Reading tracks for '$1
rm -rf /fs/isi-nas1/dfo/bioios/dfo_bioios/dar002/OUTPUT/$(cat Run/bp/2_$1|tr -d '\r')
mkdir /fs/isi-nas1/dfo/bioios/dfo_bioios/dar002/OUTPUT/$(cat Run/bp/2_$1|tr -d '\r')
track/read_track.x $1