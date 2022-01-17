class BooksController < ApplicationController
  def index
    @books = current_user.review1s.build
    @pagy, @books = pagy(current_user.review1s.order(id: :desc), items: 5)
  end
    
  def new
    @title = params[:title]
    @author = params[:author]
    @image_url = params[:image_url]
    @review1 = current_user.review1s.build　# form_with 用
    render 'books/new'
  end
    
  def search
    #ここで空の配列を作ります
  @books = []
  @title = params[:title]
  if @title.present?
      #この部分でresultsに楽天APIから取得したデータ（jsonデータ）を格納します。
      #今回は書籍のタイトルを検索して、一致するデータを格納するように設定しています。
    results = RakutenWebService::Books::Book.search({
      title: @title,
    })
    #この部分で「@books」にAPIからの取得したJSONデータを格納していきます。
    #read(result)については、privateメソッドとして、設定しております。
    results.each do |result|
      book = Book.new(read(result))
      @books << book
    end
  end
    #「@books」内の各データをそれぞれ保存していきます。
    #すでに保存済の本は除外するためにunlessの構文を記載しています。
  @books.each do |book|
    unless Book.all.include?(book)
      book.save
    end
  end
end
  def create
    @title = params[:title]
    @author = params[:author]
    @image_url = params[:image_url]
    @review1 = current_user.review1s.build(review1_params)
    if @review1.save
      flash[:success] = 'レビューを投稿しました。'
      render 'books/create'
    else
      @pagy, @review1 = pagy(current_user.review1s.order(id: :desc))
      flash.now[:danger] = 'レビューの投稿に失敗しました。'
      render 'books/create'
    end
  end

  private
  #「楽天APIのデータから必要なデータを絞り込む」、且つ「対応するカラムにデータを格納する」メソッドを設定していきます。
  def read(result)
    title = result["title"]
    author = result["author"]
    url = result["itemUrl"]
    isbn = result["isbn"]
    image_url = result["mediumImageUrl"].gsub('?_ex=120x120', '')
    {
      title: title,
      author: author,
      url: url,
      image_url: image_url,
    }
  end

  def review1_params
    params.require(:review1).permit(:content)
  end
end


