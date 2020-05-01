def asgfilter: 
  .[][] |
  {MaxSize,MinSize,DesiredCapacity,AutoScalingGroupName};

def instancefilter(field; value): 
  .[][].Instances[] | 
  field as $field | 
  value as $value | 
  select (.[$field]==$value) |
  .InstanceId;

def instanceids:
  .[][].Instances[] | .InstanceId;

def ec2_names_and_ids:
  .[][].Instances[] | 
  .InstanceId as $i |
  .Tags[] |
  select (.Key == "Name") .Value as $v |
  {"id": $i,"name": $v };

