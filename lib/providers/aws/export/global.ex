#
# Copyright 2020 Cloud Stack Lang Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
defmodule CloudStackLang.Providers.AWS.Yaml.Globals do
  @moduledoc ~S"""
  This module generate YAML stream for global.
  """
  alias CloudStackLang.Core.Util

  # In AWS CloudFormation file, some data are not attached to a resource.
  def generate_aws_global_map(aws_resources),
    do:
      aws_resources
      |> Enum.map(fn {_resource_name, _namespace, {:map, resource_properties}} ->
        resource_properties
      end)
      |> Util.merge_list_of_map()
end
