defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel

  alias Discuss.{Topic, Comment}

  def join("comments:" <> topic_id, _params, socket) do
    topic_id = String.to_integer(topic_id)
    topic = Repo.get(Topic, topic_id)

    comments =
      Comment
      |> where(topic_id: ^topic_id)
      |> Repo.all

    comments_map = Enum.map comments, fn c ->
      comment_to_map(c)
    end

    {:ok, comments_map, assign(socket, :topic, topic)}
  end

  def handle_in(name, %{"content" => content}, socket) do
    topic = socket.assigns.topic

    changeset = %Comment{user_id: socket.assigns.user_id, topic_id: socket.assigns.topic.id}
      |> Comment.changeset(%{content: content})

    #changeset = topic
    #  |> build_assoc(:comments)
    #  |> Comment.changeset(%{content: content})*/

    case Repo.insert(changeset) do
      {:ok , comment} ->
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end

    {:reply, :ok, socket}
  end

  defp comment_to_map(comment) do
   %{
     id: comment.id,
     content: comment.content
   }
 end

end
