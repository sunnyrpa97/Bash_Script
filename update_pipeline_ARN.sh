#!/bin/bash

# New Connection ARN
CONNECTION_ARN="arn:aws:codeconnections:YOUR_REGION:YOUR_ACCOUNT_ID:connection/YOUR_NEW_CONNECTION_ID"

#List of CodePipelines that need to be updated
PIPELINES=(
    "pipeline_1"
    "pipeline_2"
    "pipeline_3"
)

# Function to update the source action in a pipeline
update_pipeline_connection() {
    local pipeline_name=$1
    
    echo "Processing pipeline: ${pipeline_name}"
    
    # AWS CLI command to get the current pipeline configuration
    aws codepipeline get-pipeline --name "${pipeline_name}" > pipeline_config.json
    
    # jq command-line JSON processor to remove metadata from the configuration
    jq 'del(.metadata)' pipeline_config.json > pipeline_config_cleaned.json
    
    # jq command-line JSON processor update the connection ARN in the source action
    jq --arg conn "$CONNECTION_ARN" '.pipeline.stages[0].actions[0].configuration.ConnectionArn = $conn' pipeline_config_cleaned.json > pipeline_config_updated.json
    
    # AWS CLI command to update the pipeline
    aws codepipeline update-pipeline --cli-input-json file://pipeline_config_updated.json
    
    # Clean up temporary files
    rm pipeline_config.json pipeline_config_cleaned.json pipeline_config_updated.json
    
    echo "Updated connection for pipeline: ${pipeline_name}"
}

# Main execution
echo "Mission started to update the ARNs.............."

for pipeline in "${PIPELINES[@]}"; do
    update_pipeline_connection "$pipeline"
done

echo "Yeah, we finally did it!"
