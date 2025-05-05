resource "aws_iam_role" "drs_deploy_gha" {
  name               = "drs-deploy-gha-${local.name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.drs_deploy_gha_assume.json
}

resource "aws_iam_role_policy" "drs_deploy_gha" {
  role   = aws_iam_role.drs_deploy_gha.id
  policy = data.aws_iam_policy_document.drs_deploy_gha.json
}

resource "aws_iam_role" "ecs_task_exec" {
  name               = "ecs-task-exec-${local.name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_assume.json
}

resource "aws_iam_role_policy" "ecs_task_exec" {
  role   = aws_iam_role.ecs_task_exec.id
  policy = data.aws_iam_policy_document.ecs_task_exec.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role" "ecs_task" {
  name               = "ecs-task-${local.name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy" "ecs_task" {
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task.json
}

