require "./lib/utilities/pubmed_api"

module SeedGenerators

  PUBMED_SEARCH_TERMS = ["science", "dopamine", "algorithm", "astronomy",
                         "cardiology", "ecology", "marine", "public",
                         "nutrition", "psychology", "entymology", "mathematics"]

  def seed(num_users = 100)
    num_users.times do
      user = seed_user
      titles = get_pubmed_titles
      rand(1..5).times { seed_publication(user, titles) }
      print "."
    end
    print "\n"
  end

  private

  def seed_publication(user, titles)
    closed = (rand(3) == 0)
    created_at = Time.now - rand(100..730).days
    updated_at = created_at + rand(30..100).days

    publication = user.publications.create(title: titles.pop,
                                           closed: closed,
                                           closed_at: (closed ? updated_at : nil),
                                           created_at: created_at,
                                           updated_at: updated_at)

    rand(7).times { publication.users << seed_user }
    rand(100).times { seed_review(seed_user, publication) }
    rand(1..5).times { seed_experiment(publication, titles.pop, created_at + rand(100).days) unless titles.empty? }
  end

  def get_pubmed_titles
    search_term = PUBMED_SEARCH_TERMS[rand(PUBMED_SEARCH_TERMS.length)]
    PubmedApi.search(search_term).map{ |article| article[:title] }.shuffle.reject(&:blank?)
  end

  def seed_experiment(publication, title, created_at)
    submitted = rand(1) == 0
    updated_at = created_at + rand(50).days
    experiment = publication.experiments.create(title: title,
                                                submitted: submitted,
                                                submitted_at: (submitted ? updated_at : nil),
                                                created_at: created_at,
                                                updated_at: updated_at)

    rand(10).times { seed_review(seed_user, experiment) }
  end

  def seed_review(user, reviewable)
    user.reviews.create(reviewable: reviewable,
                        approve: (rand(4) != 0))
  end

  def seed_user
    User.create(first_name: Faker::Name.first_name,
                last_name: Faker::Name.last_name,
                title: Faker::Name.title,
                organization: Faker::University.name)
  end
end