import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "${database}", table_name = "${glue_table_raw}", transformation_ctx = "datasource0")

resolvechoice2 = ResolveChoice.apply(frame = datasource0, 
    specs = [
        ("temp","cast:float"),
        ("light","cast:float"),
        ("humidity","cast:float"),
        ("pressure","cast:float")
    ],
    transformation_ctx = "resolvechoice2")

# dropnullfields3 = DropNullFields.apply(frame = resolvechoice2, transformation_ctx = "dropnullfields3")
df = resolvechoice2.repartition(2)

S3bucket_node3 = glueContext.getSink(
    path="${processed_data_s3_path}",
    connection_type="s3",
    updateBehavior="LOG",
    partitionKeys=[],
    compression="gzip",
    enableUpdateCatalog=True,
    transformation_ctx="S3bucket_node3",
)
S3bucket_node3.setCatalogInfo(catalogDatabase="${database}", catalogTableName="${glue_table_processed}")
S3bucket_node3.setFormat("glueparquet")
S3bucket_node3.writeFrame(df)

job.commit()