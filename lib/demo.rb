require './lib/promise'
pr = Promise.fulfilled('x').then(-> { 'Success!' }, -> { 'Fail!'})
