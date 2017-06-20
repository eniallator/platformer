createBinMapReader = loadfile "../../lib/utils/binReader.lua"()

local reader = createBinMapReader({'a', 'b', 'c'})

local it = function (message, testFunc)
	print(message)
	testFunc()
	print('Success!')
end

it('get current index 1', function () assert(reader:getCurrIndex() == 1, 'Incorrect current index.') end)
it('has next 1', function () assert(reader:hasNext(), 'Should have next.') end)
it('next bit 1', function () assert(reader:nextBit() == 'a', 'Incorrect next bit.') end)
it('get current index 2', function () assert(reader:getCurrIndex() == 2, 'Incorrect current index.') end)
it('has next 2', function () assert(reader:hasNext(), 'Should have next.') end)
it('next bit 2', function () assert(reader:nextBit() == 'b', 'Incorrect next bit.') end)
it('get current index 3', function () assert(reader:getCurrIndex() == 3, 'Incorrect current index.') end)
it('has next 3', function () assert(reader:hasNext() == false, 'Shouldn\'t have next.') end)
it('next bit 3', function () assert(reader:nextBit() == 'c', 'Incorrect next bit.') end)
it('get current index 4', function () assert(reader:getCurrIndex() == 4, 'Incorrect current index.') end)
it('has next 4', function () assert(reader:hasNext() == false, 'Shouldn\'t have next.') end)
it('next bit 4', function () assert(reader:nextBit() == nil, 'Next bit should be nil.') end)
