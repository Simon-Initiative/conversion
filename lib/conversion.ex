defmodule Conversion do
  alias Conversion.Content.Readers.Pressbooks

  alias Conversion.Content.Writers.Writer
  alias Conversion.Content.Writers.Context
  alias Conversion.Content.Writers.XML

  def go do
    [input_file, output_dir] = System.argv()

    init(output_dir)

    input = read_from_file(input_file)

    {:ok, %{pages: pages, toc: toc, root: root}} = Pressbooks.segment(input)
    IO.puts("pages: #{length(pages)}")

    Enum.map(pages, fn r -> r end)
    |> Enum.map(fn s -> pressbook_to_workbook(s, output_dir) end)

    to_org(toc, output_dir)
    to_package(root, output_dir)

    IO.inspect("Done!")
  end

  def read_from_file(file) do
    File.read!(file)
  end

  def pressbook_to_workbook(segment, output_dir) do
    parsed = Pressbooks.page(segment)

    id = Map.get(parsed.data, :id)

    xml = Writer.render(%Context{}, parsed, XML)

    # File.write!(@out_path <> "/content/x-oli-workbook_page/#{index}.json", Poison.encode!(parsed))
    File.write!(output_dir <> "/content/x-oli-workbook_page/#{id}.xml", xml)
  end

  def to_org(org, output_dir) do
    parsed = Pressbooks.organization(org)

    # File.write!(@out_path <> "/organizations/default/organization.json", Poison.encode!(parsed))

    xml = Writer.render(%Context{}, parsed, XML)

    File.write!(output_dir <> "/organizations/default/organization.xml", xml)
  end

  def to_package(org, output_dir) do
    parsed = Pressbooks.package(org)
    xml = Writer.render(%Context{}, parsed, XML)
    File.write!(output_dir <> "/content/package.xml", xml)
  end

  def init(output_dir) do
    File.rm_rf(output_dir)
    File.mkdir(output_dir)
    File.mkdir(output_dir <> "/content")
    File.mkdir(output_dir <> "/content/x-oli-workbook_page")
    File.mkdir(output_dir <> "/organizations")
    File.mkdir(output_dir <> "/organizations/default")
  end
end
