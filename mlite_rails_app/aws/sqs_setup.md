
**SQS Setup Guide**

The following steps outline the setup process for configuring AWS SQS to send training requests.

1. Create an SQS Queue
- In AWS Console, go to SQS and create a new FIFO queue named ml_training_requests.fifo.
- Enable Content-Based Deduplication to automatically prevent duplicate messages.

2. Set Up IAM Permissions

- Used the same existing IAM user with Amazon sqs full access permissions

3. Add AWS Credentials to Your Application

- Store IAM credentials securely in a .env file

4. Implement Message Sending in Rails

- Create a SqsMessageSender class with a send_training_request method that formats and sends messages to the SQS queue using a message_group_id for order.

5. To send a message
   1. rails console
   2. SqsMessageSender.send_training_request({ 'model_type' => 'decision_tree', 'data_set_id' => 123 })
   3. exit
   4. You will find out the message in your sqs queue in aws


