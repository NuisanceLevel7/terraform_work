

resource "aws_s3_bucket" "bucket1" {
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

resource "aws_s3_bucket_public_access_block" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}



resource "aws_s3_bucket_policy" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id
  /* policy = file("/home/vengle/Projects/AWS/s3.remote-location-test1.json") */
  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "LockDown",
    "Statement": [
        {
            "Sid": "Restrict Outsiders",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource" = [
                aws_s3_bucket.bucket1.arn,
                "${aws_s3_bucket.bucket1.arn}/*",
            ],
            "Condition": {
                "NotIpAddress": {
                    "aws:SourceIp": [
                        "3.214.108.144",
                        "172.31.56.143",
                        "107.15.230.166"
                    ]
                },
                "StringNotEquals": {
                    "aws:SourceVpce": var.s3_endpoint
                },
                "ArnNotEquals": {
                    "aws:SourceArn": "arn:aws:iam::736922127837:role/remotelocation-s3-access-ec2"
                }
            }
        },
        {
            "Sid": "Enforce Secure xport",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource" = [
                aws_s3_bucket.bucket1.arn,
                "${aws_s3_bucket.bucket1.arn}/*",
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "False"
                }
            }
        },
        {
            "Sid": "Allow this account...",
            "Effect": "Allow",
            "Principal": {
                     "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "s3:*",
            "Resource" = [
                aws_s3_bucket.bucket1.arn,
                "${aws_s3_bucket.bucket1.arn}/*",
            ]
        }
    ]
  })
}



