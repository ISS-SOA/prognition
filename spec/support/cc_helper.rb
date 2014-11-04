module CCHelper
  def random_str(num)
    (0..num).map { ('a'..'z').to_a.sample }.join
  end
end