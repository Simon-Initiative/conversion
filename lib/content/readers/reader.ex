defmodule Conversion.Content.Readers.Reader do
  alias Conversion.Content.Model.Document
  alias Conversion.Content.Model.Organization
  alias Conversion.Content.Model.Package

  @callback segment(String.t()) ::
              {:ok, %{pages: [any()], toc: any(), root: any()}} | {:error, String.t()}
  @callback page(any()) :: {:ok, %Document{}} | {:error, String.t()}
  @callback organization(any()) :: {:ok, %Organization{}} | {:error, String.t()}
  @callback package(any()) :: {:ok, %Package{}} | {:error, String.t()}
  @callback determine_type(String.t()) :: String.t()
end
