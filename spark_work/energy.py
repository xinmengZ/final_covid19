import argparse
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType,StructField, StringType, TimestampType,FloatType,BooleanType,IntegerType,ArrayType,MapType
from pyspark.sql.functions import col, avg,count


def parseCmdLineArgs ():
    # parse the command line
    parser = argparse.ArgumentParser ()

    # add optional arguments
    parser.add_argument ("-i", "--input", help="input file")
    parser.add_argument ("-o", "--output", default="result.csv", help="output file default result.csv")
    # parse the args
    args = parser.parse_args ()

    return args

parsed_args = parseCmdLineArgs ()
print(parsed_args)


spark = SparkSession \
		.builder \
		.appName("energy") \
		.getOrCreate()
schema = StructType([ \
    StructField("id", IntegerType(),True), \
    StructField("timestamp", IntegerType(),True), \
    StructField("value", FloatType(),True), \
    StructField("property", IntegerType(), True), \
    StructField("plug_id", IntegerType(), True), \
    StructField("household_id", IntegerType(), True), \
    StructField("house_id", IntegerType(), True)
  ])

#df = spark.read.load("energy-sorted1M.csv", \
#	format="csv",sep=",",schema=schema)

df = spark.read.load(parsed_args.input, format="csv",sep=",",schema=schema)

df.printSchema()
#df.show()
results = df.groupBy("house_id", "household_id","plug_id","property").agg(avg("value"), count("*"))
#results.show(results.count(),False) truncate=False
#results.sort("house_id","household_id","plug_id","property").coalesce(1).write.csv("mycsv.csv")
results.sort("house_id","household_id","plug_id","property").coalesce(1).write.csv(parsed_args.output)
#results.write.csv("mycsv.csv")
