require "pg"
require 'csv'

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

db_connection do |conn|

  purchases = CSV.read("sales.csv", headers:true)

  unique_employees = []
  unique_customers = []
  unique_products = []
  unique_invoice_frequencies = []

  CSV.foreach("sales.csv", headers:true) do |row|
    employee_array = row['employee'].split('(')
    unique_employees << [employee_array[0].rstrip, employee_array[1].chop] unless unique_employees.include?([employee_array[0].rstrip, employee_array[1].chop])

    customer_array = row['customer_and_account_no'].split('(')
    unique_customers << [customer_array[0].rstrip, customer_array[1].chop] unless unique_customers.include?([customer_array[0].rstrip, customer_array[1].chop])

    unique_products << row['product_name'] unless unique_products.include?(row['product_name'])

    unique_invoice_frequencies << row['invoice_frequency'] unless unique_invoice_frequencies.include?(row['invoice_frequency'])
  end

  unique_employees.each do |employee|
    result = conn.exec_params("SELECT id FROM employee WHERE employee = $1", [employee[0]])
    if result.to_a.empty?
      conn.exec_params("INSERT INTO employee (employee, employee_email) VALUES ($1, $2)", [ employee[0], employee[1] ])
    end
  end

  unique_customers.each do |customer|
    result = conn.exec_params("SELECT id FROM customer WHERE customer = $1", [customer[0]])
    if result.to_a.empty?
      conn.exec_params("INSERT INTO customer (customer, customer_account_no) VALUES ($1, $2)", [customer[0], customer[1] ])
    end
  end

  unique_products.each do |product|
    result = conn.exec_params("SELECT id FROM product WHERE product_name = $1", [product])
    if result.to_a.empty?
      conn.exec_params("INSERT INTO product (product_name) VALUES ($1)", [product])
    end
  end

  unique_invoice_frequencies.each do |frequency|
    result = conn.exec_params("SELECT id FROM invoice_frequency WHERE invoice_frequency = $1", [frequency])
    if result.to_a.empty?
      conn.exec_params("INSERT INTO invoice_frequency (invoice_frequency) VALUES ($1)", [frequency])
    end
  end

  CSV.foreach("sales.csv", headers:true) do |row|
    result = conn.exec_params("SELECT id FROM purchases WHERE invoice_no = $1", [row['invoice_no']])
      if result.to_a.empty?
        employee_id = conn.exec_params("SELECT id FROM employee WHERE employee LIKE $1", ['%' + row['employee'].split('(').first.chop + '%'])[0]['id'].to_i
        customer_id = conn.exec_params("SELECT id FROM customer WHERE customer LIKE $1", ['%' + row['customer_and_account_no'].split('(').first.chop + '%'])[0]['id'].to_i
        product_id = conn.exec_params("SELECT id FROM product WHERE product_name = $1", [row['product_name']]).to_a[0]['id'].to_i
        invoice_frequency_id = conn.exec_params("SELECT id FROM invoice_frequency WHERE invoice_frequency = $1", [row['invoice_frequency']]).to_a[0]['id'].to_i

        conn.exec_params("INSERT INTO purchases (employee_id, customer_id, product_id, sale_date, sale_amount, units_sold, invoice_no, invoice_frequency_id) VALUES($1, $2, $3, $4, $5, $6, $7, $8)", [ employee_id, customer_id, product_id, row['sale_date'], row['sale_amount'], row['units_sold'], row['invoice_no'], invoice_frequency_id ])
      end
    end
  end
