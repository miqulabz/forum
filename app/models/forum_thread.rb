class ForumThread < ApplicationRecord
	extend FriendlyId

	friendly_id :title, use: :slugged

	belongs_to :user
	has_many :forum_posts, dependent: :destroy #kalo kita menghapus forum thread, otomatis forum post yg dimiliki oleh thread akan dihapus

	validates :title, presence: true, length: {maximum: 50}
	validates :content, presence: true

	def sticky?
		sticky_order != 100
		# dibaca : jika sticky_order tidak sama 100 maka action sticky? akan bernilai true
	end

	def pinit!
		self.sticky_order = 1
		# kita ingin membuat jika sticky dibuat bertambah 1 dan jika dipin sticky_order berubah
		# nilainya menjadi dua dan seterusnya
		# jadi kita buat simple dulu seperti diatas
		self.save
	end
end
