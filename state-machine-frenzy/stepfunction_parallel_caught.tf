resource "aws_sfn_state_machine" "sfn_state_machine_2" {
  name     = "${var.project_name}-state-machine-parallel-caught"
  role_arn = aws_iam_role.state_machine_role_2.arn

  definition = <<EOF
{
  "Comment": "step function testing",
  "StartAt": "first_parallel",
  "States": {
    "first_parallel": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "pass_1_1",
          "States": {
            "pass_1_1": {
                "Type": "Pass",
                "Result": {
                  "info1": "state1 was here"
                },
                "End": true
            }
          }
        },
        {
          "StartAt": "pass_1_2",
          "States": {
            "pass_1_2": {
                "Type": "Pass",
                "Result": {
                  "info2": "state2 was here"
                },
                "End": true
            }
          }
        },
        {
          "StartAt": "fail",
          "States": {
            "fail": {
                "Type": "Fail"            
            }
          }
        }      
      ],
      "Catch": [ {
              "ErrorEquals": [ "States.ALL" ],
            "Next": "fallback"
         } ],
      "Next": "second_parallel"
    },
    "fallback": {
      "Type": "Pass",
      "Next": "second_parallel"
    },
    "second_parallel": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "pass_2_1",
          "States": {
            "pass_2_1": {
                "Type": "Pass",
                "Result": {
                  "info1": "state1 was here"
                },
                "End": true
            }
          }
        },
        {
          "StartAt": "pass_2_2",
          "States": {
            "pass_2_2": {
                "Type": "Pass",
                "Result": {
                  "info2": "state2 was here"
                },
                "End": true
            }
          }
        },
        {
          "StartAt": "pass_2_3",
          "States": {
            "pass_2_3": {
                "Type": "Pass",
                "Result": {
                  "info3": "state3 was here"
                },
                "End": true
            }
          }
        }      
      ],
      "Next": "Done"
    },    
    "Done" : {
      "Type": "Succeed"
    }
  }
}
EOF
}



resource "aws_iam_role" "state_machine_role_2" {
  name = "state_machine_${var.project_name}_2"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "states.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "stepfunctions_attachment_step_2" {
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
  role       = aws_iam_role.state_machine_role_2.id
}
