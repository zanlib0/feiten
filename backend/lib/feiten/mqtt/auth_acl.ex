defmodule Feiten.Mqtt.AuthAcl do
  use Ecto.Schema

  @primary_key false
  schema "vmq_auth_acl" do
    field :mountpoint, :string, default: ""
    field :client_id, :string
    field :username, :string
    field :password, :string
    field :publish_acl, {:array, :map}
    field :subscribe_acl, {:array, :map}
  end
end
