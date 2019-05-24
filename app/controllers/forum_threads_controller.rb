class ForumThreadsController < ApplicationController
	before_action :authenticate_user!, only: [:new, :create]

	def index
		if params[:search]
			@threads = ForumThread.where('title ilike ?', "%#{params[:search]}%")
		else
			@threads = ForumThread.order(sticky_order: :asc).order(id: :desc)
		end

		@threads = @threads.paginate(per_page: 5, page: params[:page])
	end

	# detail thread
	def show
		@thread = ForumThread.friendly.find(params[:id])
		@post = ForumPost.new
		@posts = @thread.forum_posts.paginate(per_page: 3, page: params[:page])
	end

	# untuk halaman membuat thread
	def new
		@thread = ForumThread.new
	end

	# proses dari pembuatan thread
	def create
		@thread = ForumThread.new(resource_params)
		# memberitahu thread ini siapa sih user yg membuatnya,
		# yaitu user yg sedang login,
		# karena belum memiliki fitur login kita belum membuatnya,
		# jadi sementara kita buat secara hardcore manual seperti ini
		@thread.user = current_user
		if @thread.save
			redirect_to root_path
		else
			puts @thread.errors.full_messages
			# artinya kita akan menampilkan halaman new
			# bukan melakukan redirect ke new lagi
			render 'new'
		end
	end

	def edit
		@thread = ForumThread.friendly.find(params[:id])
		authorize @thread
	end

	def update
		@thread = ForumThread.friendly.find(params[:id])
		authorize @thread

		if @thread.update(resource_params)
			redirect_to forum_thread_path(@thread)
		else
			render 'new'
		end
	end

	def destroy
		@thread = ForumThread.friendly.find(params[:id])
		authorize @thread

		@thread.destroy

		redirect_to root_path, notice: 'Thread sudah dihapus'
	end

	def pinit
		@thread = ForumThread.friendly.find(params[:id])
		@thread.pinit!
		# jadi, ketika sebuat @thread memanggil method/action pinit!(method pinit! ada dimodel),
		# maka dia akan di pin di sticky
		redirect_to root_path
	end

	private

	def resource_params
		params.require(:forum_thread).permit(:title, :content)
	end
end