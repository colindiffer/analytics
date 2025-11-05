# Script to create a user account directly in the database
# Usage: mix run create_user.exs

alias Plausible.{Repo, Auth.User, Auth.Password}

# User details
name = "Colin Differ"
email = "colin@propellernet.co.uk"
password = "Bz$g%*2)G*3!vZ#a"

# Create user changeset
attrs = %{
  name: name,
  email: email,
  password: password,
  password_confirmation: password
}

case User.new(attrs) |> Repo.insert() do
  {:ok, user} ->
    IO.puts("✅ User created successfully!")
    IO.puts("ID: #{user.id}")
    IO.puts("Name: #{user.name}")
    IO.puts("Email: #{user.email}")
    IO.puts("Email verified: #{user.email_verified}")
    IO.puts("Password hash: #{String.slice(user.password_hash, 0, 20)}...")

  {:error, changeset} ->
    IO.puts("❌ Failed to create user:")
    IO.inspect(changeset.errors, label: "Errors")
end