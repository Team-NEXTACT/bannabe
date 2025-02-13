const userSchema = {
  email: 'string',
  password: 'string',
  profile_image: 'string',
  nickname: 'string',
  membership_status: 'boolean',
  membership_info: {
    start_date: 'timestamp',
    expiration_date: 'timestamp',
    renewal_count: 'number'
  },
  created_at: 'timestamp'
};

module.exports = userSchema; 