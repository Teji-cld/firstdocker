#!/bin/bash
set -e

# LocalStack accepts any non-empty dummy credentials — it never checks them.
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

ENDPOINT="http://localhost:4566"
REGION="us-east-1"

echo "Waiting for LocalStack to be ready..."
until curl -s $ENDPOINT/_localstack/health > /dev/null; do
  sleep 1
done
echo "LocalStack is up."

echo "Creating DynamoDB table: reservationsTable"
aws --endpoint-url=$ENDPOINT dynamodb create-table \
  --table-name reservationsTable \
  --attribute-definitions AttributeName=orderID,AttributeType=S \
  --key-schema AttributeName=orderID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION > /dev/null

echo "Creating SQS queue: ReservationQueue"
QUEUE_URL=$(aws --endpoint-url=$ENDPOINT sqs create-queue \
  --queue-name ReservationQueue \
  --region $REGION \
  --query 'QueueUrl' --output text)
echo "  URL: $QUEUE_URL"

QUEUE_ARN=$(aws --endpoint-url=$ENDPOINT sqs get-queue-attributes \
  --queue-url $QUEUE_URL \
  --attribute-names QueueArn \
  --region $REGION \
  --query 'Attributes.QueueArn' --output text)
echo "  ARN: $QUEUE_ARN"

echo "Creating EventBridge bus: reserve-event-bus"
aws --endpoint-url=$ENDPOINT events create-event-bus \
  --name reserve-event-bus \
  --region $REGION > /dev/null

echo "Creating rule: ReservationSubmittedRule"
aws --endpoint-url=$ENDPOINT events put-rule \
  --name ReservationSubmittedRule \
  --event-bus-name reserve-event-bus \
  --event-pattern '{"source":["reservations.app"],"detail-type":["ReservationSubmitted"]}' \
  --region $REGION > /dev/null

echo "Attaching SQS as the rule's target"
aws --endpoint-url=$ENDPOINT events put-targets \
  --rule ReservationSubmittedRule \
  --event-bus-name reserve-event-bus \
  --targets "Id=1,Arn=$QUEUE_ARN" \
  --region $REGION > /dev/null

echo ""
echo "Done — reservationsTable, ReservationQueue and reserve-event-bus now exist in LocalStack."
