variable "aws_region" {
    type = string
    nullable = false
}

variable "basename" {
  type = string
  nullable = false
}

resource "aws_iam_user" "cms-uploads-staging" {
  name = "${var.basename}-uploads-staging"
  path = "/${var.basename}/"
}

resource "aws_iam_user" "cms-uploads-production" {
  name = "${var.basename}-uploads-production"
  path = "/${var.basename}/"
}

resource "aws_iam_policy" "lightsail-deployment-policy" {
  name = "${var.basename}_deploy_bot"
  path = "/${var.basename}/"
  description = "Allows GitHub Actions to deploy AWS resources."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowDeployment",
        "Effect": "Allow",
        "Action": "lightsail:CreateContainerServiceDeployment",
        "Resource": "*"
      },
      {
        "Sid": "AllowListingContainers",
        "Effect": "Allow",
        "Action": "lightsail:GetContainerImages",
        "Resource": "*"
      },
      {
        "Sid": "AllowContainerServiceRegistryLogin",
        "Effect": "Allow",
        "Action": "lightsail:CreateContainerServiceRegistryLogin",
        "Resource": "*"
      },
      {
        "Sid": "AllowContainerRegistration",
        "Effect": "Allow",
        "Action": "lightsail:RegisterContainerImage",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_policy" "cms-uploads-policy-staging" {
  name        = "${var.basename}_cms_uploads_staging_to_s3"
  path        = "/${var.basename}/"
  description = "Allows the CMS to upload files to the S3 bucket and directory"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowUploads",
        "Effect": "Allow",
        "Action": [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource": [
          "${aws_s3_bucket.s3-uploads.arn}/*"
        ]
      },
      {
        "Sid": "AllowRootAndHomeListingOfBucket",
        "Action": [
          "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
          "${aws_s3_bucket.s3-uploads.arn}"
        ],
        "Condition": {
          "StringLike": {
            "s3:prefix": [
              "staging/*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cms-uploads-policy-production" {
  name        = "${var.basename}_cms_uploads_production_to_s3"
  path        = "/${var.basename}/"
  description = "Allows the CMS to upload files to the S3 bucket and directory"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowUploads",
        "Effect": "Allow",
        "Action": [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource": [
          "${aws_s3_bucket.s3-uploads.arn}/*"
        ]
      },
      {
        "Sid": "AllowRootAndHomeListingOfBucket",
        "Action": [
          "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
          "${aws_s3_bucket.s3-uploads.arn}"
        ],
        "Condition": {
          "StringLike": {
            "s3:prefix": [
              "production/*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "cms-uploads-staging-attach-policy" {
  user       = aws_iam_user.cms-uploads-staging.name
  policy_arn = aws_iam_policy.cms-uploads-policy-staging.arn
}

resource "aws_iam_user_policy_attachment" "cms-uploads-production-attach-policy" {
  user       = aws_iam_user.cms-uploads-production.name
  policy_arn = aws_iam_policy.cms-uploads-policy-production.arn
}