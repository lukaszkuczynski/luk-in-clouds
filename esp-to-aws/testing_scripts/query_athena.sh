# before querying get your athena re

athena_result_bucket=$(cd ../terraform && terraform output athena_result_bucket)

# echo $athena_result_bucket
query_to_athena="SELECT * FROM esp2aws.sensors_raw ORDER BY ts DESC LIMIT 5"
query_execution_id=$(aws athena start-query-execution \
    --query-string $query_to_athena \
    --query-execution-context Database=esp2aws,Catalog=AwsDataCatalog \
    --result-configuration OutputLocation=s3://$athena_result_bucket \
    --output text)
# echo $query_execution_id

# thanks to https://stackoverflow.com/questions/43338442/command-line-tool-to-access-amazon-athena
for i in $(seq 1 30); do
        queryState=$(
            aws athena get-query-execution --query-execution-id "${query_execution_id}" | jq -r ".QueryExecution.Status.State"
        );
        if [[ "${queryState}" == "SUCCEEDED" ]]; then
            break;
        fi;
        echo "  Awaiting queryExecutionId ${query_execution_id} - state was ${queryState}"
        if [[ "${queryState}" == "FAILED" ]]; then
            # exit with "bad" error code
            exit 1;
        fi;
        sleep 2
    done
aws athena get-query-results --query-execution-id $query_execution_id
# aws s3 cp s3://$athena_result_bucket/$query_execution_id.csv ./athena_result.csv
# cat ./athena_result.csv
aws athena get-query-results --query-execution-id $query_execution_id --query ResultSet.Rows[*].Data[*].VarCharValue 
