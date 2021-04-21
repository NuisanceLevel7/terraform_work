
resource "aws_s3_bucket" "b" {
  bucket = "remote-location-test1"

  tags = {
    CLOUDID        = "RemoteLocationTest"
  }


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "b" {
  bucket = aws_s3_bucket.b.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.id
  /* policy = file("/home/vengle/Projects/AWS/s3.remote-location-test1.json") */
  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "Policy1587152430504",
    "Statement": [
        {
            "Sid": "Stmt1587152093671",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource" = [
                aws_s3_bucket.b.arn,
                "${aws_s3_bucket.b.arn}/*",
            ]
            "Condition": {
                "ArnEquals": {
                    "aws:PrincipalArn": [
                        "arn:aws:iam::736922127837:role/remotelocation-s3-access-ec2",
                        "arn:aws:iam::736922127837:root"
                    ]
                }
            }
        },
        {
            "Sid": "Stmt1587152420280",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::remote-location-test1",
                "arn:aws:s3:::remote-location-test1/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "False"
                }
            }
        }
    ]

  })
}



