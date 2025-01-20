local BenchMark = {}

-- initialize getTime method
GameTime.setServerTimeShift(0) -- necessary to be able to use the following function
local getTime = GameTime.getServerTime -- cache the function to save some overhead

-- initialize variables
BenchMark.totalTime = 0
BenchMark.calls = 0

---Run the function and calculate the time it took
---@param fct function
function BenchMark.benchmark(fct,...) -- "..." is used for optional variables, these will be used in your fct
    local start = getTime() -- get start time
    fct(...) -- run your function
    BenchMark.totalTime = BenchMark.totalTime + (getTime() - start) -- get time delta to run function
    BenchMark.calls = BenchMark.calls + 1

    if BenchMark.calls % 50 == 0 then
        BenchMark.printBenchmark()
    end
end

---Print the benchmarking results in the console
function BenchMark.printBenchmark()
    if BenchMark.calls ~= 0 then
        print("Average time taken: ", (BenchMark.totalTime / BenchMark.calls) / 1000000)
        --self:resetBenchmark()
    else
        print("Need to benchmark at least once")
    end
end

---Reset the benchmark
function BenchMark.resetBenchmark()
    BenchMark.totalTime = 0
    BenchMark.calls = 0
end

return BenchMark