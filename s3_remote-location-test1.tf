
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
    "Id": "LockDown",
    "Statement": [
        {
            "Sid": "Restrict Outsiders",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::remote-location-test1",
                "arn:aws:s3:::remote-location-test1/*"
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
                    "aws:SourceVpce": "vpce-xxxxxxxxxxx"
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
            "Resource": [
                "arn:aws:s3:::remote-location-test1",
                "arn:aws:s3:::remote-location-test1/*"
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
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::remote-location-test1",
                "arn:aws:s3:::remote-location-test1/*"
            ],
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
            "Sid": "Enforce Secure xport",
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



