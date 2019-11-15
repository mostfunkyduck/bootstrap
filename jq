def asgfilter: 
  .[][] |
  {MaxSize,MinSize,DesiredCapacity,AutoScalingGroupName};

def instancefilter(field; value): 
  .[][].Instances[] | 
  field as $field | 
  value as $value | 
  select (.[$field]==$value) |
  .InstanceId;
