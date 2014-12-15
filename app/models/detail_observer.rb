class DetailObserver < ActiveRecord::Observer
	def after_create(record)
	record.logger.info("####################")
	record.logger.info("+++ DetailObserver:
	The file #{record.file_name} was added with ID #{record.id}")
	record.logger.info("####################")
end

def after_save(record)
	record.logger.info("*************************************************")
	record.logger.info("+++ DetailObserver:
	The file #{record.file_name} was edited with ID #{record.id}")

	record.logger.info("**************************************************")
end
end