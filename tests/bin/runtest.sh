#!/bin/bash
#
# A simple file based test framework.
#

JACOCO=0

usage ()
{
cat <<<EOF
$0 [options]

options:
    -h		help
	-j		run with jacoco offline instrumentation.
EOF
}

while getopts "hj" opt; do
	case "${opt}" in
		h)
			usage
			exit 0
			;;
		j)
			JACOCO=1
			;;
		*)
			usage
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "$JAQY_HOME" ]; then
	JAQY_HOME=`dirname $0`/../..
fi
JAQY_HOME=`readlink -f "$JAQY_HOME"`

if [ ! -f FILELIST ]; then
	echo "Current directory is not a test directory."
	exit 1;
fi

UNITTESTDIR=`readlink -f ..`
TESTDIR=/tmp/test.$$
INPUTDIR=${TESTDIR}/input
OUTPUTDIR=${TESTDIR}/output
CONTROLDIR=${TESTDIR}/control

JAVA=java
if [ -f /usr/lib/jvm/java-8-openjdk-amd64/bin/java ]; then
	JAVA=/usr/lib/jvm/java-8-openjdk-amd64/bin/java
fi

JACOCO_STR="-javaagent:${JAQY_HOME}/lib/org.jacoco.agent-0.8.7-runtime.jar=destfile=${JAQY_HOME}/jaqy-codecov/target/jacoco.exec,append=true"
JAQY_STR="-classpath ${JAQY_HOME}/dist/jaqy-1.2.0.jar:${JAQY_HOME}/jaqy-s3/target/jaqy-s3-1.2.0.jar:${JAQY_HOME}/jaqy-azure/target/jaqy-azure-1.2.0.jar:${JAQY_HOME}/jaqy-avro/target/jaqy-avro-1.2.0.jar com.teradata.jaqy.Main"

jq="${JAVA} -Xmx256m ${JAQY_STR}"
if [ $JACOCO -eq 1 ]; then
	jq="${JAVA} -Xmx256m ${JACOCO_STR} ${JAQY_STR}"
fi

function run ()
{
	INIT=
	if [ -f initrc ]; then
		INIT="--rcfile initrc"
	fi
	FILE=$1
	BASE=${FILE%.sql}
	CONTROL="${CONTROLDIR}/${BASE}.control"
	OUTPUT="${OUTPUTDIR}/${BASE}.txt"
	ERROR="${OUTPUTDIR}/${BASE}.diff"
	echo "$jq $INIT < ${FILE} > ${OUTPUT}"
	$jq $INIT < ${FILE} > ${OUTPUT}
	if [ -f "$CONTROL" ]; then
		diff "$CONTROL" "$OUTPUT" > $ERROR 2>/dev/null
		if [ $? -eq 0 ]; then
			echo "$FILE passed."
			rm -f "$ERROR"
			rm -f "$OUTPUT"
		else
			echo "$FILE failed."
			return 1
		fi
	else
		echo "Control file for $FILE is not found."
		return 1
	fi

	return 0
}

# setup the test directory
rm -rf "$TESTDIR"

mkdir $TESTDIR
mkdir $INPUTDIR
mkdir $OUTPUTDIR

# copy all the files into output direct
cp -r * $INPUTDIR

ln -s "${UNITTESTDIR}/common/" $TESTDIR/common
ln -s "${UNITTESTDIR}/drivers/" $TESTDIR/drivers
ln -s ${JAQY_HOME} $TESTDIR/home
mv ${INPUTDIR}/control ${CONTROLDIR}
pwd > ${TESTDIR}/testpath.txt

cd "$INPUTDIR"

HASERROR=0
for file in `cat FILELIST`; do
	if [ -f "su_$file" ]; then
		run "su_$file" || HASERROR=1
	fi
	run $file || HASERROR=1
	if [ -f "cu_$file" ]; then
		run "cu_$file" || HASERROR=1
	fi
done

if [ $HASERROR -eq 0 ]; then
	echo "test passed."
	cd /tmp
	rm -rf $TESTDIR
else
	echo "test directory is at $TESTDIR"
	exit 1
fi
